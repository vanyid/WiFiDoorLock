<?php

$filename = dirname(__FILE__) . '/status.txt';

$status = isset($_GET['status']) ? $_GET['status'] : "";
if ($status != '')
{
	file_put_contents($filename, $status);
	echo "OK";
	flush();
	die();
}


$last_check = isset($_GET['timestamp']) ? $_GET['timestamp'] : 0;
$current_modif = filemtime($filename);

while ($current_modif <= $last_check)
{
	usleep(1000);
	clearstatcache();
	$current_modif = filemtime($filename);
}

$response = array();
$response['status'] = file_get_contents($filename);
$response['door_pic'] = $response['status'] == 1 ? 'open.png' : 'close.png';
$response['timestamp'] = $current_modif;

echo json_encode($response);
flush();
?>