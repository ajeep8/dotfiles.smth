# 先用没有参数的命令得到要截屏的2个坐标，然后用2个坐标、保存文件名共5个参数截取固定位置，用于截取多页内容。

if [ "$#" -lt 5 ]; then
  xdotool getmouselocation
  echo $(basename "$0") x1 y1 x2 y2 filename
  exit 1
fi

w=$(( $3 - $1 ))
h=$(( $4 - $2 ))
import -window root -crop ${w}x${h}+$1+$2 $5.png
mogrify -repage ${w}x${h}+0+0 $5.png
#convert $5.png -repage ${w}x${h}+0+0 $5.png


