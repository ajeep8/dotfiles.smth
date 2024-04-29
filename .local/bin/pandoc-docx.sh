#!/bin/bash

#unset no_proxy ftp_proxy http_proxy https_proxy all_proxy NO_PROXY FTP_PROXY HTTPS_PROXY HTTP_PROXY ALL_PROXY

if  [ $# -lt 3 ]; then
    echo 'Usage:'
    echo 'pandoc-docx.sh src.md -o tgt.docx'
    echo 'pandoc-docx.sh --reference-doc=ref.docx src.md -o tgt.docx'
    echo 'pandoc-docx.sh --cite --csl=china-xxx.csl --bibliography=src.bib src.md -o tgt.docx'
    echo 'pandoc-docx.sh -M chapters -M chapDelim="-" -M titleDelim="" src.md -o tgt.docx'
    exit 1
fi

img="pandocone:docx"
img="ajeep/pandocone:v3.1.11_p"

num=$#
tgt=${!num}
((num -= 2))
src=${!num}

if [[ $tgt = $src ]]; then
    echo 'target should not same as source!'
    exit 1
fi

#srcdir=$(pwd)
#tmpdir=`mktemp -t -d pandocone-XXXXXX`
#cp -af * $tmpdir/
tmpdir=$(pwd)

docker run -it --rm -v $tmpdir:/data \
	-e uid=`id -u` \
	-e mermaid_url=http://192.168.100.199:8170 -e plantuml_url=http://192.168.100.199:8180 -e drawio_url=http://192.168.100.199:8166 -e py2img_url=http://192.168.100.199:8190 \
	$img -d docx --no-check-certificate \
	$@ 
        #-e https_proxy=http://10.222.1.1:7890 \

return_code=$?
if [ $return_code -ne 0 ]; then
    echo "pandoc执行失败，返回值为 $return_code"
    exit
fi

dp() {
  docker run -it --rm -u $(id -u) -v $tmpdir:/data --entrypoint "" $img python "$@"
}

echo 'lstStyle：列表应用样式“列表”“列表2"..."列表5"'
dp /python/lstStyle.py $tgt -o $tgt

echo 'Table Style: 表格使用Table Grid样式，表格内容和台头都使用Table Content样式，表标题小四(12)'
dp /python/TableStyle.py $tgt -o $tgt -s "Table Grid" -b "Table Content" -t "Table Content" -c 12

echo 'Figure Style: 图片居中，图标题小四(12)'
dp /python/FigureStyle.py $tgt -o $tgt -s "Captioned Figure" -a c -c 12

if [ -f "ref-cover.docx" ]; then
  echo '增加封面'
  docker run -it --rm -v $tmpdir:/data --entrypoint /bin/sh $img /bin/addcover.sh $tgt 4 $tgt /data/ref-cover.docx
fi

#cp $tmpdir/$tgt .

#  docker run -it --rm -v $(pwd):/data  --entrypoint="/usr/local/bin/python" ajeep/pandocone:v3.1.2_p /python/show-docxstyle.py kg-build.docx
