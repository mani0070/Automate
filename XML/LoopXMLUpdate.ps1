$filePath  = 'G:\BlogScripts\cars.xml'
    $xml=New-Object XML
    $xml.Load($filePath)
    $nodes = $xml.SelectNodes('/carsdealers/car/Gear');
    foreach($node in $nodes) 
    {
        $node.SetAttribute('type', 'Manual');
    }
    $xml.Save($filePath)
