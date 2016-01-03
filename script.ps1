# Dumps all gallileo video to csv file
# position, videoId, seen, published, title, description (trimmed),





$key = "AIzaSyCrb1f-QjPwO9w-sB6qQTNdQ-vEdjMx7Ek"
$playlist = "UUpNzWUlO6PVb_v7chefBnig"

$parameters = [ordered] @{
    part = "snippet"
    maxResults = 50
    playlistId = $playlist
    fields = "nextPageToken%2Citems%2Fsnippet%2Ftitle%2Citems%2Fsnippet%2FpublishedAt%2Citems%2Fsnippet%2Fdescription%2Citems%2Fsnippet%2Fposition%2Citems%2Fsnippet%2FresourceId%2FvideoId" # nextPageToken,items/snippet/title,items/snippet/publishedAt,items/snippet/description,items/snippet/position,items/snippet/resourceId/videoId
    key = $key
}

$parametersText = ($parameters.Keys | where{ $parameters.$psitem } | foreach{ "$psitem=$($parameters.$psitem)" }) -join "&"
$query = "https://www.googleapis.com/youtube/v3/playlistItems?$parametersText"

# about 8 seconds in total
$results = @()
$response = Invoke-RestMethod $query
$results += $response

while( $response.nextPageToken )
{
    Write-Progress "Got next page" $response.nextPageToken
    $parameters.pageToken = $response.nextPageToken
    $parametersText = ($parameters.Keys | where{ $parameters.$psitem } | foreach{ "$psitem=$($parameters.$psitem)" }) -join "&"
    $query = "https://www.googleapis.com/youtube/v3/playlistItems?$parametersText"
    $response = Invoke-RestMethod $query
    $results += $response
}







$a = Invoke-RestMethod $query
$a.items
$a.items.snippet



