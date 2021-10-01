#Gets video files from current directory
echo '-Getting List of videos'
$vList = (Get-ChildItem *.avi, *.divx, *.dvx, *.f4p, *.f4v, *.fli, *.flv,
 *.mp4, *.mov, *.m4v, *.mpg, *.mpeg, *.wmv, *.mkv, *.xvid, *.webm -File)
$pList = @()
#Gets pixel amount for each video
echo '-Getting pixel load for: '
foreach($video in $vList)
{
    $frames = $(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=nb_frames $video.FullName) -as [int]
    if($frames -lt 1){ $frames = $(ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 $video.FullName) -as [int] }
    $frameWidth = $(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=width $video.FullName) -as [int]
    $frameHeight = $(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=height $video.FullName) -as [int]
    $pixels = $($frameWidth * $frameHeight) * $frames
    $pList+=$pixels
    echo $video.FullName
    echo $pixels
}
#Finds distinct possibilities
echo '-Getting possibilities'
$lefts = New-Object System.Collections.ArrayList
$rights = New-Object System.Collections.ArrayList
for($i = 0;$i -lt $pList.Count-1;$i++)
    {
        $left = New-Object System.Collections.ArrayList
        $right = New-Object System.Collections.ArrayList
        $curr = $i
        for($h = $curr;$h -ge 0;$h--)
        {
            $left.Add($h) > $null
        }
        for($j = $curr+1;$j -lt $pList.Count;$j++)
        {
            
            $right.Add($j) > $null
        }
        $curr+=1
        $lefts.Add($left) > $null
        $rights.Add($right) >$null
    }
#Gets difference for each possibility
echo '-Calculating solutions'
$diffs = @()
for($i = 0;$i -lt $vList.Count-1;$i++)
{
    $sumLeft = 0
    $sumRight = 0
    foreach($cur in $lefts[$i])
    {
        $sumLeft+=$pList[$cur]
    }
    foreach($cur in $rights[$i])
    {
        $sumRight+=$pList[$cur]
    }
    $diff = [Math]::Abs($sumLeft - $sumRight)
    $diffs+=$diff
}
#Gets possibility with smallest difference
echo '-Selecting best solution'
$min = $diffs[0]
foreach($diff in $diffs)
{
    if($diff -lt $min)
    {
        $min = $diff
    }
}
$vMin = [array]::indexof($diffs,$min)
#Create Directories
echo '-Creating Directories'
$path1 = $('.\'+'RIFE'+(1))
$path2 = $('.\'+'RIFE'+(2))
if($(Test-Path $path1) -ne $true){New-Item -Path $path1 -ItemType Directory}
if($(Test-Path $path2) -ne $true){New-Item -Path $path2 -ItemType Directory}
echo '-Moving Files'
foreach($num in $lefts[$vMin])
{
    Move-Item $vList[$num].FullName.Replace("[", "``[").replace("]", "``]") $path1
}
foreach($num in $rights[$vMin])
{
    Move-Item $vList[$num].FullName.Replace("[", "``[").replace("]", "``]") $path2
}
echo 'vMin'
$vMin
echo 'Min'
$min
echo 'Diffs'
$diffs
echo 'Lefts'
$lefts[$vMin]
echo 'Rights'
$rights[$vMin]