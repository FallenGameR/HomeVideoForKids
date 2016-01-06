# Dumps all gallileo video to csv file
# position, videoId, seen, published, title, description (trimmed),
param
(
    # "UUpNzWUlO6PVb_v7chefBnig" Галилео
    # "UU-3Pifrk-FZOorhBa20WOKw" ilyalarionov uploads
    $playlist,
    # "Зверята.csv"
    $output = "Output.csv"
)

# Key is from shelltube project
# TODO: create a separate key for application
$key = "AIzaSyCrb1f-QjPwO9w-sB6qQTNdQ-vEdjMx7Ek"

$parameters = [ordered] @{
    part = "snippet"
    maxResults = 50
    playlistId = $playlist
    fields = "nextPageToken%2Citems%2Fsnippet%2Ftitle%2Citems%2Fsnippet%2FpublishedAt%2Citems%2Fsnippet%2Fdescription%2Citems%2Fsnippet%2Fposition%2Citems%2Fsnippet%2FresourceId%2FvideoId" # nextPageToken,items/snippet/title,items/snippet/publishedAt,items/snippet/description,items/snippet/position,items/snippet/resourceId/videoId
    key = $key
}

$parametersText = ($parameters.Keys | where{ $parameters.$psitem } | foreach{ "$psitem=$($parameters.$psitem)" }) -join "&"
$query = "https://www.googleapis.com/youtube/v3/playlistItems?$parametersText"

# about 8 seconds in total for galileo
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

$parsed = foreach( $item in $results.items.snippet )
{
    [PSCustomObject] [ordered] @{
        position = $item.position
        videoId = $item.resourceId.videoId
        seen = $false
        published = [datetimeoffset]::Parse($item.publishedAt)
        title = $item.title
        description = ($item.description -split "`r?`n" | foreach trim | where{ $psitem }) -join ". " -replace "\.\.", "."
    }
}

$parsed | sort published | Export-Csv $output -NoTypeInformation -NoOverwrite -Encoding UTF8
