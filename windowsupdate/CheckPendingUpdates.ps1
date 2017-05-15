$criteria = "Type='software' and IsAssigned=1 and IsHidden=0 and IsInstalled=0"
$searcher = (New-Object -COM Microsoft.Update.Session).CreateUpdateSearcher()
$updates  = $searcher.Search($criteria).Updates

if ($updates.Count -ne 0) {
 Write-host "Updates pending, Please review and take action"
  $updates |% title
} else {
  Write-host "Machine fully updated"
}
