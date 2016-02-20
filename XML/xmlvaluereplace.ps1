$filePath  = 'G:\BlogScripts\cars.xml'
    $xml=[XML] (Get-Content $filePath)
    $nodes = Select-Xml -Xml $xml -XPath '//@type'
    foreach($node in $nodes) 
    {
        $node.Node.Value =$node.Node.Value.Replace('Auto','Manual')
    }
    $xml.Save($filePath)
