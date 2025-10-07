#!/bin/bash
if [[ $# -lt 2 ]] ; then
	echo 'pandoc --extract-media ./ -t gfm-raw_html src.docx -o tgt.md'
	echo '然后需要先做：'
	echo '1. 删除目录；'
	echo '2. 查找[TABLE]复制粘贴所有缺少的表格'
	echo '3. Usage: ppandoc.sh source.md target.md'  # 不确定本sh是否有bug，因此保留源文件
	echo '4. 整理metadata'
	echo
	echo '后期检查：'
	echo '- 检查标题是否都正确'
	echo
	echo 'ToDo:'
	echo '- 层级列表需要修正'
	echo
	echo '改名.docx为.docx.zip，mkdir docxzip; cd docxzip; unzip ../xxx.docx.zip'
	echo '查看word/embeddings目录，这些文件对应的内容都不出现在.md文件中，需要补上'
    exit 1
fi

t="/var/tmp/ppandoc.tmp"
cp $1 $t

# 如果是 GNU linux, 无需 -i 之后的''

#sed -i 's/[^#][^#]*#/#/' $t	# 删除标题前的错误编号

sed -i 's/ *>  *//' $t	# 删除引用

sed -i 's/图 *[0-9]\+- *[0-9]\+ */图-1 /' $t  
sed -i 's/图 *[0-9]\+‑ *[0-9]\+ */图-1 /' $t  
sed -i 's/表 *[0-9]\+‑ *[0-9]\+ */表-1 /' $t  
sed -i 's/表格 *[0-9]\+‑ *[0-9]\+ */表-1 /' $t  

# sed -i 's/\(="[0-9]\.[0-9]\{3\}\)[0-9]*in"/\1in" /g' $t	# 截短width/height
# sed -n 's/\"\([0-9]\+\.[0-9][0-9][0-9]\)[0-9]\+in\"/\1in/pg' %t	# 降低图片精度宽高
sed -i 's/width=\"\([0-9]\+\.[0-9][0-9][0-9]\)[0-9]\+in\"/width=\1in/g' $t
sed -i 's/height=\"\([0-9]\+\.[0-9][0-9][0-9]\)[0-9]\+in\"/height=\1in/g' $t
sed -i -E ':a ; $!N ; s/\n(height=)/ \1/ ; ta ; P ; D' $t	# 将height=开头的行与上一行合并
sed -i '/^!\[[^]]*$/{N;s/\n/ /p}' $t	# 将被截断的^![xx/x]合并
sed -i -e '/^!\[/{N;N;s/^!\[\(.*\)\]\(.*\)\n.*\n.\{0,2\}图-[0-9-]\+ \(.*\)/!\[\3\]\2/}' $t	# 将图片和隔1行的"图-xxx"整合
sed -i -e '/^!\[/{N;N;s/^!\[\(.*\)\]\(.*\)\n.*\n.\{0,2\}图 *[0-9-]\+ *\(.*\)/!\[\3\]\2/}' $t	# 将图片和隔1行的"图-xxx"整合

# html图片改为md图片
sed -i 's/<img src="\(media\/image[0-9]*\.[a-zA-Z]*\)" style="width:\([0-9\.]*in\);height:\([0-9\.]*in\)" alt="\([^"]*\)"* \/>/![\4](\1){width="\2" height="\3"}/g' $t
sed -i 's/<img src="\(media\/image[0-9]*\.[a-zA-Z]*\)" style="width:\([0-9\.]*in\);height:\([0-9\.]*in\)" \/>/![](\1){width="\2" height="\3"}/g' $t

# 净化表格
#sed -i 's/| *--* *|/| -- |/g' $t
#sed -i 's/| *----* *|/| -- |/g' $t
sed -i 's/| \+/| /g' $t
sed -i 's/ \+|/ |/g' $t
sed -i 's/表格-[0-9]\+ */Table: /' $t  
sed -i 's/表格 *[0-9]\+- *[0-9]\+ */Table: /' $t  
sed -i 's/^表 *[0-9-]\+ */Table: /' $t

# 删除错误软换行
sed -e ':a' -e 'N' -e '$!ba' -i -e 's/\n\n/..nnrr../g' $t
sed -e ':a' -e 'N' -e '$!ba' -i -e 's/| *\n *|/..ttbb../g' $t
sed -e ':a' -e 'N' -e '$!ba' -i -e 's/\n//g' $t
# if GNU Linux
sed -i 's/..ttbb../|\n|/g' $t
sed -i 's/..nnrr../\n\n/g' $t
# if MacOS
#sed -i 's/..ttbb../|\
#|/g' $t
#sed -i 's/..nnrr../\
#\
#/g' $t


sed -i 's/\$\$\([^$]*\)\$\$/\$\$\n\1\n\$\$/' $t	# 公式$$独占一行

#sed 's/in"height/in" height/g'

# 标准化列表 sed -i 's/^ *(\([0-9][0-9]*\)) */\1. /' $t	# (12)-->12.
sed -i 's/^ *（\([0-9][0-9]*\)） */\1. /' $t	# （12）-->12.
sed -i 's/^ *\([0-9][0-9]*\)) */\1. /' $t	# 12)-->12.
sed -i 's/^ *\([a-z]\+\)) */1. /' $t	# a)-->1.
sed -i 's/^ *\([0-9][0-9]*\)）/\1. /' $t	# 12）-->12.
sed -i 's/^ *\([0-9][0-9]*\)。 */\1. /' $t	# 12。-->12.
sed -i 's/^ *\([0-9][0-9]*\)、 */\1. /' $t	# 12、-->12.
sed -i 's/\(^ *[0-9]\+\.\)\([^ ]\+\)/\1 \2/' $t # 12.abc --> 12. abc
sed -i 's/^\([0-9]\+\)\\\. */\1\. /' $t  # 2\. --> 2.
sed -i '/^SourceURL:/d' $t  # 删除SourceURL开头的行

#cp $t $2; exit 0

sed -i 's/• */- /' $t
sed -i 's/- \+/- /' $t
sed -i 's/^\. \+/- /' $t

# 删除插图说明
sed -i 's/!\[[^]]*\](media/![](media/g' $t
#sed -i 's/&nbsp;//' $t
sed -e ':a' -e 'N' -e '$!ba' -i -e 's/\n&nbsp;\n//g' $t
sed -e ':a' -e 'N' -e '$!ba' -i -e 's/\n# *\n//g' $t
sed -e ':a' -e 'N' -e '$!ba' -i -e 's/\n[0-9]. *\n//g' $t

# 删除手工章节编号
sed -i 's/# [0-9.、][0-9.、]*/# /' $t
sed -i 's/^ *[0-9]\+. \+\(#\+\) \+/\1 /' $t	#  1.  ###  abc -> ### abc
sed -i 's/^ *[0-9]\+. \+[0-9]\+. \+\(#\+\) \+/\1 /' $t  #  1. 1.  ###  abc -> ### abc
sed -i 's/^\(#\+\) \+\*\*\(.\+\)\*\*/\1 \2/' $t	#  ###  **abc** -> ### abc
sed -i 's/\\\*\*//g' $t # 删除手工的**加粗
sed -i 's/\*\\\*//g' $t # 删除手工的**加粗
sed -i 's/\*\*//g' $t # 删除手工的**加粗


sed -i 's/\[\([ A-Za-z]*\)\](file:[^)]*) *|/\1 |/' $t	# 删除表格内的file链接(http链接保留)
sed -i 's/\([^{]\+\){#.\+ \.样式[0-9]\+}/\1/' $t	# 删除标题样式

sed -i '/^|\( |\)\+$/{N;N;s/.*\n\(.*\)\n\(.*\)/\2\n\1/}' $t  # 将无台头表格第一行改为台头

sed -i 's/|[ \*]\+/| /g' $t
sed -i 's/[ \*]\+|/ |/g' $t

# underline
sed -i -E 's/(^|[^*])\*([^*]+)\*/\1[\2]{.underline}/g' $t # vim中：:%s/\(^\|\s\)\*\([^*][^*]*[^*]\)\*/\1[\2]{.underline}/g

# 删除<200b>
sed -i 's/\xE2\x80\x8B//g' $t

cp $t $2

# 快速替换多个文件的URL
# sed -i 's/](https:\/\/wiki.buudoo.com\/public\/images\/dev\/m_kaleido\//](m_kaleido\//' xxx.md

