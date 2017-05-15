$searcher = (New-Object -COM Microsoft.Update.Session).CreateUpdateSearcher()
$HistoryCount = $Searcher.GetTotalHistoryCount()
$Updates = $Searcher.QueryHistory(0,$HistoryCount)
$Updates | % Title
