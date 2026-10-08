#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
/usr/bin/time -p mkdir -p dist
/usr/bin/time -p test -f dist/index.html
/usr/bin/time -p bash -c 'if [ -f package.json ]; then if [ -f package-lock.json ]; then npm ci --no-audit --no-fund; else npm install --no-audit --no-fund; fi; if node -e "const p=require(\"./package.json\");process.exit(p.scripts&&p.scripts.build?0:1)"; then npm run build; fi; fi; true'
/usr/bin/time -p node -e 'const fs=require("fs"),path=require("path");const project=process.cwd();const dir=path.resolve(project,"dist");if(!fs.existsSync(path.join(dir,"index.html"))){console.error("Static deployment output must contain index.html.");process.exit(1)}const outDir=process.env.OPENCODE_WEB_DIR||"/home/runner/work/_temp/omgithub-web";fs.mkdirSync(outDir,{recursive:true});fs.writeFileSync(path.join(outDir,"deployment-output.json"),JSON.stringify({project,directory:dir}));console.log("deployment-output: "+path.join(outDir,"deployment-output.json")+" -> "+dir);'
/usr/bin/time -p node -e '
const http=require("http"),fs=require("fs"),path=require("path");
const root=path.resolve(process.cwd(),"dist");
const port=Number(process.env.PORT||3000);
const mime={".html":"text/html",".js":"application/javascript",".css":"text/css",".json":"application/json",".svg":"image/svg+xml",".png":"image/png",".jpg":"image/jpeg",".webp":"image/webp",".wasm":"application/wasm"};
const server=http.createServer((req,res)=>{
try{
const u=new URL(req.url,"http://localhost");
let p=path.resolve(root,"."+decodeURIComponent(u.pathname));
if(p!==root&&!p.startsWith(root+"/")){res.writeHead(404);res.end();return}
let f=p;try{if(fs.statSync(f).isDirectory())f=path.join(f,"index.html")}catch{ f=path.join(root,"index.html"); }
try{
const content=fs.readFileSync(f);
res.setHeader("Content-Type",mime[path.extname(f)]||"application/octet-stream");
res.setHeader("Cache-Control","no-cache");
res.end(content);
}catch{res.writeHead(404);res.end("Not found")}
}catch(e){res.writeHead(404);res.end("Not found")}
});
server.listen(port,"0.0.0.0",()=>console.log("Serving "+root+" on port "+port));
'
