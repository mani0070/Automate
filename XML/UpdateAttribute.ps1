$filePath  = 'G:\BlogScripts\cars.xml'
      $xml=New-Object XML
      $xml.Load($filePath)
      $node=$xml.carsdealers.car.Gear 
      $node.type='Maual'
      $xml.Save($filePath)
