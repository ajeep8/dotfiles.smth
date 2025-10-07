#!/bin/bash
if  [[ $# -eq 0 ]]; then
    echo 'Usage:'
    echo 'pandoc-pptx.sh src.md -o tgt.pptx'
    echo 'pandoc-pptx.sh --reference-doc=ref.pptx src.md -o tgt.pptx'
    exit 1
fi

img="ajeep/pandocone:v3.1.11_p"

num=$#
tgt=${!num}
((num -= 2))
src=${!num}

if [[ $tgt = $src ]]; then
    echo 'target should not same as source!'
    exit 1
fi

srcdir=$(pwd)
#tmpdir=`mktemp -t -d pandocone-XXXXXX`
#cp -af * $tmpdir/
tmpdir=$(pwd)

ref=""
if [ -f "ref.pptx" ]; then
  ref="--reference-doc=ref.pptx"
fi

docker run -it --rm -v $tmpdir:/data \
	-e uid=`id -u` \
	-e mermaid_url=http://10.222.1.81:8170 -e plantuml_url=http://10.222.1.81:8180 -e drawio_url=http://10.222.1.81:8166  -e py2img_url=http://10.222.1.81:8190 \
	$img -d pptx --no-check-certificate \
	$ref $@
	#-e https_proxy=http://10.222.1.81:7890 \
#	-v $HOME/.pandoc/defaults/pptx.yaml:/root/.pandoc/defaults/pptx.yaml \

#docker run -it --rm -v $tmpdir:/data -e uid=`id -u` -e https_proxy=http://10.222.1.1:7890 pandocone:docx -d pptx $@

echo 'rowcol: 处理表格colspan、rowspan'
#dp /python/rowcol.py $tgt
python ~/mygit/github/pandocOne/python/rowcol.py $tgt
    
echo 'softLF: 表格中的\n变成换行'
#dp /python/softLF.py $tgt
python ~/mygit/github/pandocOne/python/softLF.py $tgt


#cp $tmpdir/$tgt .
