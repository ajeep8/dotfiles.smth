--[[
diagram-generator – create images and figures from code blocks.

This Lua filter is used to create images with or without captions
from code blocks. Currently PlantUML, GraphViz, Tikz, and Python
can be processed. For further details, see README.md.

Copyright: © 2018-2021 John MacFarlane <jgm@berkeley.edu>,
             2018 Florian Schätzig <florian@schaetzig.de>,
             2019 Thorsten Sommer <contact@sommer-engineering.com>,
             2019-2021 Albert Krewinkel <albert+pandoc@zeitkraut.de>
License:   MIT – see LICENSE file for details
]]
-- Module pandoc.system is required and was added in version 2.7.3
PANDOC_VERSION:must_be_at_least '2.7.3'

local system = require 'pandoc.system'
local utils = require 'pandoc.utils'
local stringify = function (s)
  return type(s) == 'string' and s or utils.stringify(s)
end
local with_temporary_directory = system.with_temporary_directory
local with_working_directory = system.with_working_directory

-- The Inkscape path. In order to define an Inkscape version per pandoc
-- document, use the meta data to define the key "inkscape_path".
local inkscape_path = os.getenv("INKSCAPE") or "inkscape"

-- The Python path. In order to define a Python version per pandoc document,
-- use the meta data to define the key "python_path".
local python_path = os.getenv("PYTHON") or "python"

-- The Python environment's activate script. Can be set on a per document
-- basis by using the meta data key "activatePythonPath".
local python_activate_path = os.getenv("PYTHON_ACTIVATE")

-- The Java path. In order to define a Java version per pandoc document,
-- use the meta data to define the key "java_path".
local java_path = os.getenv("JAVA_HOME")
if java_path then
    java_path = java_path .. package.config:sub(1,1) .. "bin"
        .. package.config:sub(1,1) .. "java"
else
    java_path = "java"
end

-- The dot (Graphviz) path. In order to define a dot version per pandoc
-- document, use the meta data to define the key "dot_path".
local dot_path = os.getenv("DOT") or "dot"
local mmdc_path = os.getenv("MERMAID_BIN") or "mmdc"
local base64_path = os.getenv("BASE64") or "base64"
local drawio_path = os.getenv("DrawIO") or "drawio"
local mermaid_url = os.getenv("mermaid_url")
local plantuml_url= os.getenv("plantuml_url")
local drawio_url= os.getenv("drawio_url")

-- The pdflatex path. In order to define a pdflatex version per pandoc
-- document, use the meta data to define the key "pdflatex_path".
local pdflatex_path = os.getenv("PDFLATEX") or "pdflatex"

-- The asymptote path. There is also the metadata variable
-- "asymptote_path".
local asymptote_path = os.getenv ("ASYMPTOTE") or "asy"

-- The default format is SVG i.e. vector graphics:
local filetype = "svg"
local mimetype = "image/svg+xml"
local filetype = "png"
local mimetype = "image/png"

-- Check for output formats that potentially cannot use SVG
-- vector graphics. In these cases, we use a different format
-- such as PNG:
if FORMAT == "docx" then
  filetype = "png"
  mimetype = "image/png"
elseif FORMAT == "pptx" then
  filetype = "png"
  mimetype = "image/png"
elseif FORMAT == "rtf" then
  filetype = "png"
  mimetype = "image/png"
end

-- Execute the meta data table to determine the paths. This function
-- must be called first to get the desired path. If one of these
-- meta options was set, it gets used instead of the corresponding
-- environment variable:
function Meta(meta)
  inkscape_path = stringify(
    meta.inkscape_path or meta.inkscapePath or inkscape_path
  )
  python_path = stringify(
    meta.python_path or meta.pythonPath or python_path
  )
  python_activate_path =
    meta.activate_python_path or meta.activatePythonPath or python_activate_path
  python_activate_path = python_activate_path and stringify(python_activate_path)
  java_path = stringify(
    meta.java_path or meta.javaPath or java_path
  )
  dot_path = stringify(
    meta.path_dot or meta.dotPath or dot_path
  )
  mmdc_path = stringify(
    meta.path_mmdc or meta.mmdcPath or mmdc_path
  )
  base64_path = stringify(
    meta.path_base64 or meta.base64Path or base64_path
  )
  drawio_path = stringify(
    meta.path_drawio or meta.drawioPath or drawio_path
  )
  pdflatex_path = stringify(
    meta.pdflatex_path or meta.pdflatexPath or pdflatex_path
  )
  asymptote_path = stringify(
     meta.asymptote_path or meta.asymptotePath or asymptote_path
  )
end

-- Call dot (GraphViz) in order to generate the image
-- (thanks @muxueqz for this code):
local function graphviz(code, filetype)
  print("graphviz graph...")
  return pandoc.pipe(dot_path, {"-T" .. filetype}, code)
end

local function plantuml(puml, filetype)
  --local handle=io.popen("echo '" .. puml .. "' | hexdump -v -e '/1 \"%02x\"'")
  --cmd="echo '" .. puml .. "' | od -A n -t x1 | sed -e ':a;N;s/\\n//g;ta'|sed -e 's/ //g'"
  print("PlantUML renderer...")
  
  result=""
  for i = 1, #puml do
    result=result .. string.format("%02x",string.byte(string.sub(puml, i, i)))
  end
  cmd="curl -s --noproxy '*' --location --request GET '" .. plantuml_url .. "/" .. filetype .. "/~h" .. result .. "'"
  handle=io.popen(cmd)
  result=handle:read("*a")
  return result
end

local function mermaid(code, filetype)
  print("mermaid renderer...")
  cmd = "curl -s --noproxy '*' --location --request POST '" .. mermaid_url .. "/generate?type=png' --header 'Content-Type: text/plain' --data-raw '" .. code .. "'"
  handle=io.popen(cmd)
  result=handle:read("*a")
  return result
end

local function drawio(code, filetype)
  print("drawio renderer...")
  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, 'w')
  f:write(code)
  f:close()

  if filetype == 'png' then
    cmd = 'curl -s -d @' .. tmpfile .. ' -H "Accept: image/png" ' .. drawio_url .. '/convert_file?scale={2.0}'
  else
    cmd = 'curl -s -d @' .. tmpfile .. ' -H "Accept: image/svg+xml; encoding=utf-8" ' .. drawio_url .. '/convert_file?scale={2.0}'
  end
  -- os.execute(cmd .. ' --output /data/' .. string.sub(tmpfile,6) .. '.' .. filetype)
  handle=io.popen(cmd)
  result=handle:read("*a")
  return result
end

local function diagram(code, filetype)
  print("diagram graph: DrawIO in wiki.js")
  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, 'w')
  f:write(code)
  f:close()
  local cmd=base64_path and base64_path .. ' -d ' .. tmpfile .. ' > ' .. tmpfile .. '.svg'
  os.execute(cmd)
  if filetype == 'png' then
    --convert -background white -font NSimSun -density 300 bdp1.svg bdp1.png
    --drawio -x -f xml -u bdp1.svg -o bdp1.xml
    --drawio -x -f png -s 2 -b 1 -p 0 bdp1.xml -o bdp1.png
    cmd=drawio_path and drawio_path .. ' -x -f xml -u ' .. tmpfile .. '.svg -o ' .. tmpfile .. '.xml'
    os.execute(cmd)
    cmd=drawio_path and drawio_path .. ' -x -f png -s 2 -b 1 -p 0 ' .. tmpfile .. '.xml -o ' .. tmpfile .. '.png'
    os.execute(cmd)
  end
  local r = io.open(tmpfile .. '.' .. filetype, 'rb')

  local imgData = nil
  if r then
    imgData = r:read("*all")
    r:close()
  else
    io.stderr:write(string.format("File '%s' could not be opened", tmpfile .. '.' .. filetype))
    error 'Could not create image from drawio in wiki.js.'
  end

  os.remove(tmpfile .. '*')

  return imgData
end
--
-- TikZ
--

--- LaTeX template used to compile TikZ images. Takes additional
--- packages as the first, and the actual TikZ code as the second
--- argument.
local tikz_template = [[
\documentclass{standalone}
\usepackage{tikz}
%% begin: additional packages
%s
%% end: additional packages
\begin{document}
%s
\end{document}
]]

-- Returns a function which takes the filename of a PDF or SVG file
-- and a target filename, and writes the input as the given format.
-- Returns `nil` if conversion into the target format is not possible.
local function convert_with_inkscape(filetype)
  -- Build the basic Inkscape cmd for the conversion
  local inkscape_output_args
  if filetype == 'png' then
    inkscape_output_args = '--export-png="%s" --export-dpi=300'
  elseif filetype == 'svg' then
    inkscape_output_args = '--export-plain-svg="%s"'
  else
    return nil
  end
  return function (pdf_file, outfile)
    local inkscape_cmd = string.format(
      '"%s" --without-gui --file="%s" ' .. inkscape_output_args,
      inkscape_path,
      pdf_file,
      outfile
    )
    local cmd_output = io.popen(inkscape_command)
    -- TODO: print output when debugging.
    cmd_output:close()
  end
end

--- Compile LaTeX with Tikz code to an image
local function tikz2image(src, filetype, additional_packages)
  local convert = convert_with_inkscape(filetype)
  -- Bail if there is now known way from PDF to the target format.
  if not convert then
    error(string.format("Don't know how to convert pdf to %s.", filetype))
  end
  return with_temporary_directory("tikz2image", function (tmpdir)
    return with_working_directory(tmpdir, function ()
      -- Define file names:
      local file_template = "%s/tikz-image.%s"
      local tikz_file = file_template:format(tmpdir, "tex")
      local pdf_file = file_template:format(tmpdir, "pdf")
      local outfile = file_template:format(tmpdir, filetype)

      -- Build and write the LaTeX document:
      local f = io.open(tikz_file, 'w')
      f:write(tikz_template:format(additional_packages or '', src))
      f:close()

      -- Execute the LaTeX compiler:
      pandoc.pipe(pdflatex_path, {'-output-directory', tmpdir, tikz_file}, '')

      convert(pdf_file, outfile)

      -- Try to open and read the image:
      local img_data
      local r = io.open(outfile, 'rb')
      if r then
        img_data = r:read("*all")
        r:close()
      else
        -- TODO: print warning
      end

      return img_data
    end)
  end)
end

-- Run Python to generate an image:
local function py2image(code, filetype)
  print("py2image graph...")

  -- Define the temp files:
  local outfile = string.format('%s.%s', os.tmpname(), filetype)
  local pyfile = os.tmpname()

  -- Replace the desired destination's file type in the Python code:
  local extendedCode = string.gsub(code, "%$FORMAT%$", filetype)

  -- Replace the desired destination's path in the Python code:
  extendedCode = string.gsub(extendedCode, "%$DESTINATION%$", outfile)

  -- Write the Python code:
  local f = io.open(pyfile, 'w')
  f:write(extendedCode)
  f:close()

  -- Execute Python in the desired environment:
  local pycmd = python_path .. ' ' .. pyfile
  local cmd = python_activate_path
    and python_activate_path .. ' && ' .. pycmd
    or pycmd
  os.execute(cmd)

  -- Try to open the written image:
  local r = io.open(outfile, 'rb')
  local imgData = nil

  -- When the image exist, read it:
  if r then
    imgData = r:read("*all")
    r:close()
  else
    io.stderr:write(string.format("File '%s' could not be opened", outfile))
    error 'Could not create image from python code.'
  end

  -- Delete the tmp files:
  os.remove(pyfile)
  os.remove(outfile)

  return imgData
end

--
-- Asymptote
--

local function asymptote(code, filetype)
  local convert
  if filetype ~= 'svg' and filetype ~= 'png' then
    error(string.format("Conversion to %s not implemented", filetype))
  end
  return with_temporary_directory(
    "asymptote",
    function(tmpdir)
      return with_working_directory(
        tmpdir,
        function ()
          local asy_file = "pandoc_diagram.asy"
          local svg_file = "pandoc_diagram.svg"
          local f = io.open(asy_file, 'w')
          f:write(code)
          f:close()

          pandoc.pipe(asymptote_path, {"-f", "svg", "-o", "pandoc_diagram", asy_file}, "")

          local r
          if filetype == 'svg' then
            r = io.open(svg_file, 'rb')
          else
            local png_file = "pandoc_diagram.png"
            convert_with_inkscape("png")(svg_file, png_file)
            r = io.open(png_file, 'rb')
          end

          local img_data
          if r then
            img_data = r:read("*all")
            r:close()
          else
            error("could not read asymptote result file")
          end
          return img_data
      end)
  end)
end

-- Executes each document's code block to find matching code blocks:
function CodeBlock(block)
  -- Using a table with all known generators i.e. converters:
  local converters = {
    plantuml = plantuml,
    graphviz = graphviz,
    mermaid = mermaid,
    diagram = diagram,
    drawio = drawio,
    tikz = tikz2image,
    py2image = py2image,
    asymptote = asymptote,
  }

  -- Check if a converter exists for this block. If not, return the block
  -- unchanged.
  local img_converter = converters[block.classes[1]]
  if not img_converter then
    return nil
  end

  -- Call the correct converter which belongs to the used class:
  local success, img = pcall(img_converter, block.text,
      filetype, block.attributes["additionalPackages"] or nil)

  -- Bail if an error occured; img contains the error message when that
  -- happens.
  if not (success and img) then
    io.stderr:write(tostring(img or "no image data has been returned."))
    io.stderr:write('\n')
    error 'Image conversion failed. Aborting.'
  end

  -- If we got here, then the transformation went ok and `img` contains
  -- the image data.

  -- Create figure name by hashing the image content
  local fname = pandoc.sha1(img) .. "." .. filetype

  -- Store the data in the media bag:
  pandoc.mediabag.insert(fname, mimetype, img)

  local enable_caption = nil

  -- If the user defines a caption, read it as Markdown.
  local caption = block.attributes.caption
    and pandoc.read(block.attributes.caption).blocks[1].content
    or {}
  if block.attributes.caption then
    print(block.attributes.caption)
  end

  -- use This code replace upper, but can't display fig caption
  --local caption={}
  --if block.attributes.caption then
  --  if block.attributes.caption ~= "" then
  --    local caption = block.attributes.caption
  --      and pandoc.read(block.attributes.caption).blocks[1].content
  --      or {}
  --    print(block.attributes.caption)
  --  end
  --end

  -- A non-empty caption means that this image is a figure. We have to
  -- set the image title to "fig:" for pandoc to treat it as such.
  local title = #caption > 0 and "fig:" or ""

  -- Transfer identifier and other relevant attributes from the code
  -- block to the image. Currently, only `name` is kept as an attribute.
  -- This allows a figure block starting with:
  --
  --     ```{#fig:example .plantuml caption="Image created by **PlantUML**."}
  --
  -- to be referenced as @fig:example outside of the figure when used
  -- with `pandoc-crossref`.
  local img_attr = {
    id = block.identifier,
    name = block.attributes.name,
    width = block.attributes.width,
    height = block.attributes.height
  }

  -- Create a new image for the document's structure. Attach the user's
  -- caption. Also use a hack (fig:) to enforce pandoc to create a
  -- figure i.e. attach a caption to the image.
  local img_obj = pandoc.Image(caption, fname, title, img_attr)

  -- Finally, put the image inside an empty paragraph. By returning the
  -- resulting paragraph object, the source code block gets replaced by
  -- the image:
  return pandoc.Para{ img_obj }
end

-- Normally, pandoc will run the function in the built-in order Inlines ->
-- Blocks -> Meta -> Pandoc. We instead want Meta -> Blocks. Thus, we must
-- define our custom order:
return {
  {Meta = Meta},
  {CodeBlock = CodeBlock},
}

