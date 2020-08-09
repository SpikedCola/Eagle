<?php

require_once('PHPExcel/PHPExcel.php');

if (count($argv) < 2) {
	echo "Usage: ....";
	die;	
}

$file = realpath($argv[1]);
if (!file_exists($file)) {
	echo "\"{$argv[1]}\" not found";
	die;
}

$pathinfo = pathinfo($file);
$path = $pathinfo['dirname'].DIRECTORY_SEPARATOR;
$filename = $pathinfo['filename'];
$outputFile = $path.$filename.'.xlsx';

$purchaseRequestTemplate = __DIR__.'/Purchase Request Template.xlsx';
$outputFolder = 'Z:/Purchase Requests/';

MakePurchaseRequest('pcb');
MakePurchaseRequest('parts');

function MakePurchaseRequest($type) {	
	global $purchaseRequestTemplate, $filename, $outputFolder, $path;
	
	$reader = PHPExcel_IOFactory::createReader('Excel2007');
	$excel = $reader->load($purchaseRequestTemplate);
	$excel->setActiveSheetIndex(0);
	$sheet = $excel->getActiveSheet();

	switch ($type) {
		case 'parts':
			$date = date('Y-m-d');
			$dkBOM = '0000000000';
			$supplier = 'Digikey';
		
			$outputFilename = $outputFolder."Purchase Request - {$filename} Parts - {$supplier} - {$date}.xlsx";
	
			$sheet->setCellValue('B7', $supplier); // supplier
			$sheet->setCellValue('B9', PHPExcel_Shared_Date::PHPToExcel($date)); // date
			$sheet->setCellValue('F9', 'Jordan Skoblenick'); // requested by
			$sheet->setCellValue('J9', 'Jordan Skoblenick'); // signature
			
			$sheet->getStyle('A12')->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_TOP);
			$sheet->setCellValue('A12', "Digikey BOM # {$dkBOM}"); // part #
			
			$sheet->setCellValue('C12', "Parts for \"{$filename}\""); // brief description
			$sheet->setCellValue('G12', 'Prototyping'); // purpose
			$sheet->setCellValue('J12', '> 0'); // qty 
			
			$sheet->setCellValue('K12', '44.22'); // unit price
			$sheet->getStyle('K12')->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_CURRENCY_USD_SIMPLE); // format unit price as currency
			
			break;
			
		case 'pcb':
			$date = date('Y-m-d');
			$supplier = 'DirtyPCBs';
			$amount = '$xx USD';
			$zipFileName = 'REPLACEME';

			$possibleZipFile = glob($path.$filename.'*.zip');
			if (count($possibleZipFile) > 0) {
				$zipFileName = basename($possibleZipFile[0]);
			}
			
			$outputFilename = $outputFolder."Purchase Request - {$filename} PCBs - {$supplier} - {$date}.xlsx";
	
			$sheet->setCellValue('B7', $supplier); // supplier
			$sheet->setCellValue('B9', PHPExcel_Shared_Date::PHPToExcel($date)); // date
			$sheet->setCellValue('F9', 'Jordan Skoblenick'); // requested by
			$sheet->setCellValue('J9', 'Jordan Skoblenick'); // signature
			
			$sheet->getStyle('A12')->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_TOP);
			$sheet->setCellValue('A12', $zipFileName); // zip file	
			
			$sheet->setCellValue('C12', "PCBs for \"{$filename}\""); // brief description
			$sheet->setCellValue('G12', 'Prototyping'); // purpose
			$sheet->setCellValue('J12', '> 0'); // qty 
			
			// @TODO: parse width/height
			$width = $height = 5;
			$quoteAmount = GetPCBQuote($width, $height);
			if ($quoteAmount) {
					$amount = $quoteAmount;
			}
			$sheet->setCellValue('K12', $amount); // unit price
			$sheet->getStyle('K12')->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_CURRENCY_USD_SIMPLE); // format unit price as currency
			
			break;
			
		default:
			echo "unhandled purchase request type: {$type}";
			die;
	}
	
	$writer = PHPExcel_IOFactory::createWriter($excel, 'Excel2007');
	$writer->save($outputFilename);
}

function GetPCBQuote($width, $height) {
	$quoteUrl = 'http://dev.dangerousprototypes.com/store/pcbs/quote';
	$shippingQuoteUrl = 'http://dev.dangerousprototypes.com/cart/country_shipment_options/';
	$cost = 0;
	$shipping = 0;
	
	$pcbOptions = [
		'material' => 'FR4 proto',
		'layers' => 2,
		'quantity' => 'Protopack ±10',
		'color' => 'Green',
		'thickness' => '1.6mm',
		'coating' => 'ENIG', // HASL / ENIG
		'size' => 'Custom', // max 5x5, max 10x10
		'size_h' => $height,
		'size_w' => $width,
		'stencil' => 'None',
		'processing' => 'Normal',
		'copper' => '1oz',
		'vgroove' => 'None',
		'panelize' => 'None',
	];
	$pcbOptionsJson = json_encode($pcbOptions);
	
	// quote pcb itself
	$quoteData = [
		'pcb' => $pcbOptionsJson
	];
	$ch = curl_init($quoteUrl);
	curl_setopt($ch, CURLOPT_REFERER, 'J Skoba\'s Purchase Request Script <jordan@skoba.ca> (Hi mom and dad!)');
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $quoteData);
	$quoteResponse = curl_exec($ch);
	curl_close($ch);
	
	$responseJson = json_decode($quoteResponse);
	$cost = $responseJson->cost_sell;
	$weight = $responseJson->weight;
	
	// quote shipping
	$shippingQuoteData = [
		'country_code' => 'Canada',
		'total_weight' => $weight
	];
	$ch = curl_init($shippingQuoteUrl);
	curl_setopt($ch, CURLOPT_REFERER, 'J Skoba\'s Purchase Request Script <jordan@skoba.ca> (Hi mom and dad!)');
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $shippingQuoteData);
	$shippingQuoteResponse = curl_exec($ch);
	curl_close($ch);
	
	$shippingQuoteResponseJson = json_decode($shippingQuoteResponse);
	
	$options = '<html><head></head><body>'.$shippingQuoteResponseJson->html.'</body></html>';
	
	$dom = new DOMDocument();
	$dom->loadHTML($options);
	$xpath = new DOMXPath($dom);
	$option = $xpath->query('//option[@value="DHL-BGA"]');
	if ($option->length) {
		$shipping = (float)$option->item(0)->getAttribute('data-value');
	}
	else {
		echo 'failed to find option DHL-BGA?';
		var_dump($shippingQuoteResponse); 
		die;
	}
	
	return $cost + $shipping;
}
