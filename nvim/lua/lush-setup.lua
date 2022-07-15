vim.o.background = "dark"
vim.g.codeschool_contrast_dark = "hard"

local lush = require('lush')
local hsl = lush.hsl
local codeschool = require('codeschool')
local setup = codeschool.setup({
  plugins = {
    "cmp",
    "fzf",
    "gitgutter",
    "gitsigns",
    "lsp",
    "nerdtree",
    "packer",
    "telescope",
    "treesitter"
  },
  langs = {
    "css",
    "html",
    "js",
    "json",
    "jsx",
    "lua",
    "markdown",
    "ruby",
    "typescript",
    "viml",
    "xml"
  }
})
local spec = lush.extends({ setup }).with(function()
  return {
    Comment { fg = "#8e9292", }, -- Comment        xxx ctermfg=244 guifg=#8e9292
    DevIconAi { fg = "#cbcb41", }, -- DevIconAi      xxx ctermfg=185 guifg=#cbcb41
    DevIconAwk { fg = "#4d5a5e", }, -- DevIconAwk     xxx ctermfg=59 guifg=#4d5a5e
    DevIconBabelrc { fg = "#cbcb41", }, -- DevIconBabelrc xxx ctermfg=185 guifg=#cbcb41
    DevIconBash { fg = "#89e051", }, -- DevIconBash    xxx ctermfg=113 guifg=#89e051
    DevIconBashProfile { fg = "#89e051", }, -- DevIconBashProfile xxx ctermfg=113 guifg=#89e051
    DevIconBashrc { fg = "#89e051", }, -- DevIconBashrc  xxx ctermfg=113 guifg=#89e051
    DevIconBat { fg = "#c1f12e", }, -- DevIconBat     xxx ctermfg=154 guifg=#c1f12e
    DevIconBinaryGLTF { fg = "#ffb13b", }, -- DevIconBinaryGLTF xxx ctermfg=215 guifg=#ffb13b
    DevIconBmp { fg = "#a074c4", }, -- DevIconBmp     xxx ctermfg=140 guifg=#a074c4
    DevIconBrewfile { fg = "#701516", }, -- DevIconBrewfile xxx ctermfg=52 guifg=#701516
    DevIconC { fg = "#599eff", }, -- DevIconC       xxx ctermfg=75 guifg=#599eff
    DevIconCMake { fg = "#6d8086", }, -- DevIconCMake   xxx ctermfg=66 guifg=#6d8086
    DevIconCMakeLists { fg = "#6d8086", }, -- DevIconCMakeLists xxx ctermfg=66 guifg=#6d8086
    DevIconCPlusPlus { fg = "#f34b7d", }, -- DevIconCPlusPlus xxx ctermfg=204 guifg=#f34b7d
    DevIconClojure { fg = "#8dc149", }, -- DevIconClojure xxx ctermfg=107 guifg=#8dc149
    DevIconClojureC { fg = "#8dc149", }, -- DevIconClojureC xxx ctermfg=107 guifg=#8dc149
    DevIconClojureDart { fg = "#519aba", }, -- DevIconClojureDart xxx ctermfg=67 guifg=#519aba
    DevIconClojureJS { fg = "#519aba", }, -- DevIconClojureJS xxx ctermfg=67 guifg=#519aba
    DevIconCobol { fg = "#005ca5", }, -- DevIconCobol   xxx ctermfg=25 guifg=#005ca5
    DevIconCoffee { fg = "#cbcb41", }, -- DevIconCoffee  xxx ctermfg=185 guifg=#cbcb41
    DevIconConf { fg = "#6d8086", }, -- DevIconConf    xxx ctermfg=66 guifg=#6d8086
    DevIconConfigRu { fg = "#701516", }, -- DevIconConfigRu xxx ctermfg=52 guifg=#701516
    DevIconConfiguration { fg = "#ececec", }, -- DevIconConfiguration xxx ctermfg=231 guifg=#ececec
    DevIconCp { fg = "#519aba", }, -- DevIconCp      xxx ctermfg=67 guifg=#519aba
    DevIconCpp { fg = "#519aba", }, -- DevIconCpp     xxx ctermfg=67 guifg=#519aba
    DevIconCrystal { fg = "#000000", }, -- DevIconCrystal xxx ctermfg=16 guifg=#000000
    DevIconCs { fg = "#596706", }, -- DevIconCs      xxx ctermfg=58 guifg=#596706
    DevIconCsh { fg = "#4d5a5e", }, -- DevIconCsh     xxx ctermfg=59 guifg=#4d5a5e
    DevIconCson { fg = "#cbcb41", }, -- DevIconCson    xxx ctermfg=185 guifg=#cbcb41
    DevIconCss { fg = "#42a5f5", }, -- DevIconCss     xxx ctermfg=39 guifg=#42a5f5
    DevIconCsv { fg = "#89e051", }, -- DevIconCsv     xxx ctermfg=113 guifg=#89e051
    DevIconCxx { fg = "#519aba", }, -- DevIconCxx     xxx ctermfg=67 guifg=#519aba
    DevIconD { fg = "#427819", }, -- DevIconD       xxx ctermfg=64 guifg=#427819
    DevIconDart { fg = "#03589c", }, -- DevIconDart    xxx ctermfg=25 guifg=#03589c
    DevIconDb { fg = "#dad8d8", }, -- DevIconDb      xxx ctermfg=188 guifg=#dad8d8
    DevIconDefault { fg = "#6d8086", }, -- DevIconDefault xxx ctermfg=66 guifg=#6d8086
    DevIconDesktopEntry { fg = "#563d7c", }, -- DevIconDesktopEntry xxx ctermfg=60 guifg=#563d7c
    DevIconDiff { fg = "#41535b", }, -- DevIconDiff    xxx ctermfg=59 guifg=#41535b
    DevIconDoc { fg = "#185abd", }, -- DevIconDoc     xxx ctermfg=25 guifg=#185abd
    DevIconDockerfile { fg = "#384d54", }, -- DevIconDockerfile xxx ctermfg=59 guifg=#384d54
    DevIconDrools { fg = "#ffafaf", }, -- DevIconDrools  xxx ctermfg=217 guifg=#ffafaf
    DevIconDropbox { fg = "#0061fe", }, -- DevIconDropbox xxx ctermfg=27 guifg=#0061fe
    DevIconDsStore { fg = "#41535b", }, -- DevIconDsStore xxx ctermfg=59 guifg=#41535b
    DevIconDump { fg = "#dad8d8", }, -- DevIconDump    xxx ctermfg=188 guifg=#dad8d8
    DevIconEdn { fg = "#519aba", }, -- DevIconEdn     xxx ctermfg=67 guifg=#519aba
    DevIconEex { fg = "#a074c4", }, -- DevIconEex     xxx ctermfg=140 guifg=#a074c4
    DevIconEjs { fg = "#cbcb41", }, -- DevIconEjs     xxx ctermfg=185 guifg=#cbcb41
    DevIconElm { fg = "#519aba", }, -- DevIconElm     xxx ctermfg=67 guifg=#519aba
    DevIconEnv { fg = "#faf743", }, -- DevIconEnv     xxx ctermfg=226 guifg=#faf743
    DevIconEpp { fg = "#ffa61a", }, -- DevIconEpp     xxx guifg=#ffa61a
    DevIconErb { fg = "#701516", }, -- DevIconErb     xxx ctermfg=52 guifg=#701516
    DevIconErl { fg = "#b83998", }, -- DevIconErl     xxx ctermfg=132 guifg=#b83998
    DevIconEx { fg = "#a074c4", }, -- DevIconEx      xxx ctermfg=140 guifg=#a074c4
    DevIconExs { fg = "#a074c4", }, -- DevIconExs     xxx ctermfg=140 guifg=#a074c4
    DevIconFavicon { fg = "#cbcb41", }, -- DevIconFavicon xxx ctermfg=185 guifg=#cbcb41
    DevIconFennel { fg = "#fff3d7", }, -- DevIconFennel  xxx ctermfg=230 guifg=#fff3d7
    DevIconFish { fg = "#4d5a5e", }, -- DevIconFish    xxx ctermfg=59 guifg=#4d5a5e
    DevIconFs { fg = "#519aba", }, -- DevIconFs      xxx ctermfg=67 guifg=#519aba
    DevIconFsharp { fg = "#519aba", }, -- DevIconFsharp  xxx ctermfg=67 guifg=#519aba
    DevIconFsi { fg = "#519aba", }, -- DevIconFsi     xxx ctermfg=67 guifg=#519aba
    DevIconFsscript { fg = "#519aba", }, -- DevIconFsscript xxx ctermfg=67 guifg=#519aba
    DevIconFsx { fg = "#519aba", }, -- DevIconFsx     xxx ctermfg=67 guifg=#519aba
    DevIconGDScript { fg = "#6d8086", }, -- DevIconGDScript xxx ctermfg=66 guifg=#6d8086
    DevIconGemfile { fg = "#701516", }, -- DevIconGemfile xxx ctermfg=52 guifg=#701516
    DevIconGemspec { fg = "#701516", }, -- DevIconGemspec xxx ctermfg=52 guifg=#701516
    DevIconGif { fg = "#a074c4", }, -- DevIconGif     xxx ctermfg=140 guifg=#a074c4
    DevIconGitAttributes { fg = "#41535b", }, -- DevIconGitAttributes xxx ctermfg=59 guifg=#41535b
    DevIconGitCommit { fg = "#41535b", }, -- DevIconGitCommit xxx ctermfg=59 guifg=#41535b
    DevIconGitConfig { fg = "#41535b", }, -- DevIconGitConfig xxx ctermfg=59 guifg=#41535b
    DevIconGitIgnore { fg = "#41535b", }, -- DevIconGitIgnore xxx ctermfg=59 guifg=#41535b
    DevIconGitLogo { fg = "#f14c28", }, -- DevIconGitLogo xxx ctermfg=202 guifg=#f14c28
    DevIconGitModules { fg = "#41535b", }, -- DevIconGitModules xxx ctermfg=59 guifg=#41535b
    DevIconGitlabCI { fg = "#e24329", }, -- DevIconGitlabCI xxx ctermfg=166 guifg=#e24329
    DevIconGo { fg = "#519aba", }, -- DevIconGo      xxx ctermfg=67 guifg=#519aba
    DevIconGodotProject { fg = "#6d8086", }, -- DevIconGodotProject xxx ctermfg=66 guifg=#6d8086
    DevIconGruntfile { fg = "#e37933", }, -- DevIconGruntfile xxx ctermfg=173 guifg=#e37933
    DevIconGulpfile { fg = "#cc3e44", }, -- DevIconGulpfile xxx ctermfg=167 guifg=#cc3e44
    DevIconGvimrc { fg = "#019833", }, -- DevIconGvimrc  xxx ctermfg=29 guifg=#019833
    DevIconH { fg = "#a074c4", }, -- DevIconH       xxx ctermfg=140 guifg=#a074c4
    DevIconHaml { fg = "#eaeae1", }, -- DevIconHaml    xxx ctermfg=188 guifg=#eaeae1
    DevIconHbs { fg = "#f0772b", }, -- DevIconHbs     xxx ctermfg=208 guifg=#f0772b
    DevIconHeex { fg = "#a074c4", }, -- DevIconHeex    xxx ctermfg=140 guifg=#a074c4
    DevIconHh { fg = "#a074c4", }, -- DevIconHh      xxx ctermfg=140 guifg=#a074c4
    DevIconHpp { fg = "#a074c4", }, -- DevIconHpp     xxx ctermfg=140 guifg=#a074c4
    DevIconHrl { fg = "#b83998", }, -- DevIconHrl     xxx ctermfg=132 guifg=#b83998
    DevIconHs { fg = "#a074c4", }, -- DevIconHs      xxx ctermfg=140 guifg=#a074c4
    DevIconHtm { fg = "#e34c26", }, -- DevIconHtm     xxx ctermfg=166 guifg=#e34c26
    DevIconHtml { fg = "#e44d26", }, -- DevIconHtml    xxx ctermfg=202 guifg=#e44d26
    DevIconHxx { fg = "#a074c4", }, -- DevIconHxx     xxx ctermfg=140 guifg=#a074c4
    DevIconIco { fg = "#cbcb41", }, -- DevIconIco     xxx ctermfg=185 guifg=#cbcb41
    DevIconImportConfiguration { fg = "#ececec", }, -- DevIconImportConfiguration xxx ctermfg=231 guifg=#ececec
    DevIconIni { fg = "#6d8086", }, -- DevIconIni     xxx ctermfg=66 guifg=#6d8086
    DevIconJava { fg = "#cc3e44", }, -- DevIconJava    xxx ctermfg=167 guifg=#cc3e44
    DevIconJl { fg = "#a270ba", }, -- DevIconJl      xxx ctermfg=133 guifg=#a270ba
    DevIconJpeg { fg = "#a074c4", }, -- DevIconJpeg    xxx ctermfg=140 guifg=#a074c4
    DevIconJpg { fg = "#a074c4", }, -- DevIconJpg     xxx ctermfg=140 guifg=#a074c4
    DevIconJs { fg = "#cbcb41", }, -- DevIconJs      xxx ctermfg=185 guifg=#cbcb41
    DevIconJson { fg = "#cbcb41", }, -- DevIconJson    xxx ctermfg=185 guifg=#cbcb41
    DevIconJsx { fg = "#519aba", }, -- DevIconJsx     xxx ctermfg=67 guifg=#519aba
    DevIconKotlin { fg = "#f88a02", }, -- DevIconKotlin  xxx ctermfg=208 guifg=#f88a02
    DevIconKotlinScript { fg = "#f88a02", }, -- DevIconKotlinScript xxx ctermfg=208 guifg=#f88a02
    DevIconKsh { fg = "#4d5a5e", }, -- DevIconKsh     xxx ctermfg=59 guifg=#4d5a5e
    DevIconLeex { fg = "#a074c4", }, -- DevIconLeex    xxx ctermfg=140 guifg=#a074c4
    DevIconLess { fg = "#563d7c", }, -- DevIconLess    xxx ctermfg=60 guifg=#563d7c
    DevIconLhs { fg = "#a074c4", }, -- DevIconLhs     xxx ctermfg=140 guifg=#a074c4
    DevIconLicense { fg = "#cbcb41", }, -- DevIconLicense xxx ctermfg=185 guifg=#cbcb41
    DevIconLock { fg = "#bbbbbb", }, -- DevIconLock    xxx ctermfg=250 guifg=#bbbbbb
    DevIconLog { fg = "#ffffff", }, -- DevIconLog     xxx ctermfg=15 guifg=#ffffff
    DevIconLua { fg = "#51a0cf", }, -- DevIconLua     xxx ctermfg=74 guifg=#51a0cf
    DevIconMakefile { fg = "#6d8086", }, -- DevIconMakefile xxx ctermfg=66 guifg=#6d8086
    DevIconMarkdown { fg = "#519aba", }, -- DevIconMarkdown xxx ctermfg=67 guifg=#519aba
    DevIconMaterial { fg = "#b83998", }, -- DevIconMaterial xxx ctermfg=132 guifg=#b83998
    DevIconMd { fg = "#ffffff", }, -- DevIconMd      xxx ctermfg=15 guifg=#ffffff
    DevIconMdx { fg = "#519aba", }, -- DevIconMdx     xxx ctermfg=67 guifg=#519aba
    DevIconMint { fg = "#87c095", }, -- DevIconMint    xxx ctermfg=108 guifg=#87c095
    DevIconMixLock { fg = "#a074c4", }, -- DevIconMixLock xxx ctermfg=140 guifg=#a074c4
    DevIconMjs { fg = "#f1e05a", }, -- DevIconMjs     xxx ctermfg=221 guifg=#f1e05a
    DevIconMl { fg = "#e37933", }, -- DevIconMl      xxx ctermfg=173 guifg=#e37933
    DevIconMli { fg = "#e37933", }, -- DevIconMli     xxx ctermfg=173 guifg=#e37933
    DevIconMotoko { fg = "#9772fb", }, -- DevIconMotoko  xxx ctermfg=99 guifg=#9772fb
    DevIconMustache { fg = "#e37933", }, -- DevIconMustache xxx ctermfg=173 guifg=#e37933
    DevIconNPMIgnore { fg = "#e8274b", }, -- DevIconNPMIgnore xxx ctermfg=161 guifg=#e8274b
    DevIconNPMrc { fg = "#e8274b", }, -- DevIconNPMrc   xxx ctermfg=161 guifg=#e8274b
    DevIconNim { fg = "#f3d400", }, -- DevIconNim     xxx ctermfg=220 guifg=#f3d400
    DevIconNix { fg = "#7ebae4", }, -- DevIconNix     xxx ctermfg=110 guifg=#7ebae4
    DevIconNodeModules { fg = "#e8274b", }, -- DevIconNodeModules xxx ctermfg=161 guifg=#e8274b
    DevIconOPUS { fg = "#f88a02", }, -- DevIconOPUS    xxx ctermfg=208 guifg=#f88a02
    DevIconOpenTypeFont { fg = "#ececec", }, -- DevIconOpenTypeFont xxx ctermfg=231 guifg=#ececec
    DevIconPackageJson { fg = "#e8274b", }, -- DevIconPackageJson xxx guifg=#e8274b
    DevIconPackageLockJson { fg = "#7a0d21", }, -- DevIconPackageLockJson xxx guifg=#7a0d21
    DevIconPackedResource { fg = "#6d8086", }, -- DevIconPackedResource xxx ctermfg=66 guifg=#6d8086
    DevIconPdf { fg = "#b30b00", }, -- DevIconPdf     xxx ctermfg=124 guifg=#b30b00
    DevIconPhp { fg = "#a074c4", }, -- DevIconPhp     xxx ctermfg=140 guifg=#a074c4
    DevIconPl { fg = "#519aba", }, -- DevIconPl      xxx ctermfg=67 guifg=#519aba
    DevIconPm { fg = "#519aba", }, -- DevIconPm      xxx ctermfg=67 guifg=#519aba
    DevIconPng { fg = "#a074c4", }, -- DevIconPng     xxx ctermfg=140 guifg=#a074c4
    DevIconPp { fg = "#ffa61a", }, -- DevIconPp      xxx guifg=#ffa61a
    DevIconPpt { fg = "#cb4a32", }, -- DevIconPpt     xxx ctermfg=167 guifg=#cb4a32
    DevIconPrisma { fg = "#ffffff", }, -- DevIconPrisma  xxx ctermfg=15 guifg=#ffffff
    DevIconProcfile { fg = "#a074c4", }, -- DevIconProcfile xxx ctermfg=140 guifg=#a074c4
    DevIconProlog { fg = "#e4b854", }, -- DevIconProlog  xxx ctermfg=179 guifg=#e4b854
    DevIconPromptPs1 { fg = "#4d5a5e", }, -- DevIconPromptPs1 xxx ctermfg=59 guifg=#4d5a5e
    DevIconPsb { fg = "#519aba", }, -- DevIconPsb     xxx ctermfg=67 guifg=#519aba
    DevIconPsd { fg = "#519aba", }, -- DevIconPsd     xxx ctermfg=67 guifg=#519aba
    DevIconPy { fg = "#ffbc03", }, -- DevIconPy      xxx ctermfg=61 guifg=#ffbc03
    DevIconPyc { fg = "#ffe291", }, -- DevIconPyc     xxx ctermfg=67 guifg=#ffe291
    DevIconPyd { fg = "#ffe291", }, -- DevIconPyd     xxx ctermfg=67 guifg=#ffe291
    DevIconPyo { fg = "#ffe291", }, -- DevIconPyo     xxx ctermfg=67 guifg=#ffe291
    DevIconR { fg = "#358a5b", }, -- DevIconR       xxx ctermfg=65 guifg=#358a5b
    DevIconRake { fg = "#701516", }, -- DevIconRake    xxx ctermfg=52 guifg=#701516
    DevIconRakefile { fg = "#701516", }, -- DevIconRakefile xxx ctermfg=52 guifg=#701516
    DevIconRb { fg = "#701516", }, -- DevIconRb      xxx ctermfg=52 guifg=#701516
    DevIconRlib { fg = "#dea584", }, -- DevIconRlib    xxx ctermfg=180 guifg=#dea584
    DevIconRmd { fg = "#519aba", }, -- DevIconRmd     xxx ctermfg=67 guifg=#519aba
    DevIconRproj { fg = "#358a5b", }, -- DevIconRproj   xxx ctermfg=65 guifg=#358a5b
    DevIconRs { fg = "#dea584", }, -- DevIconRs      xxx ctermfg=180 guifg=#dea584
    DevIconRss { fg = "#fb9d3b", }, -- DevIconRss     xxx ctermfg=215 guifg=#fb9d3b
    DevIconSass { fg = "#f55385", }, -- DevIconSass    xxx ctermfg=204 guifg=#f55385
    DevIconScala { fg = "#cc3e44", }, -- DevIconScala   xxx ctermfg=167 guifg=#cc3e44
    DevIconScss { fg = "#f55385", }, -- DevIconScss    xxx ctermfg=204 guifg=#f55385
    DevIconSettingsJson { fg = "#854cc7", }, -- DevIconSettingsJson xxx ctermfg=98 guifg=#854cc7
    DevIconSh { fg = "#4d5a5e", }, -- DevIconSh      xxx ctermfg=59 guifg=#4d5a5e
    DevIconSig { fg = "#e37933", }, -- DevIconSig     xxx ctermfg=173 guifg=#e37933
    DevIconSlim { fg = "#e34c26", }, -- DevIconSlim    xxx ctermfg=166 guifg=#e34c26
    DevIconSln { fg = "#854cc7", }, -- DevIconSln     xxx ctermfg=98 guifg=#854cc7
    DevIconSml { fg = "#e37933", }, -- DevIconSml     xxx ctermfg=173 guifg=#e37933
    DevIconSolidity { fg = "#519aba", }, -- DevIconSolidity xxx ctermfg=67 guifg=#519aba
    DevIconSql { fg = "#dad8d8", }, -- DevIconSql     xxx ctermfg=188 guifg=#dad8d8
    DevIconStyl { fg = "#8dc149", }, -- DevIconStyl    xxx ctermfg=107 guifg=#8dc149
    DevIconSuo { fg = "#e37933", }, -- DevIconSuo     xxx ctermfg=98 guifg=#e37933
    DevIconSvelte { fg = "#ff3e00", }, -- DevIconSvelte  xxx ctermfg=202 guifg=#ff3e00
    DevIconSvg { fg = "#ffb13b", }, -- DevIconSvg     xxx ctermfg=215 guifg=#ffb13b
    DevIconSwift { fg = "#e37933", }, -- DevIconSwift   xxx ctermfg=173 guifg=#e37933
    DevIconSystemVerilog { fg = "#019833", }, -- DevIconSystemVerilog xxx ctermfg=29 guifg=#019833
    DevIconTcl { fg = "#1e5cb3", }, -- DevIconTcl     xxx ctermfg=67 guifg=#1e5cb3
    DevIconTerminal { fg = "#31b53e", }, -- DevIconTerminal xxx ctermfg=71 guifg=#31b53e
    DevIconTex { fg = "#3d6117", }, -- DevIconTex     xxx ctermfg=58 guifg=#3d6117
    DevIconTextResource { fg = "#cbcb41", }, -- DevIconTextResource xxx ctermfg=185 guifg=#cbcb41
    DevIconTextScene { fg = "#a074c4", }, -- DevIconTextScene xxx ctermfg=140 guifg=#a074c4
    DevIconToml { fg = "#6d8086", }, -- DevIconToml    xxx ctermfg=66 guifg=#6d8086
    DevIconTor { fg = "#519aba", }, -- DevIconTor     xxx ctermfg=67 guifg=#519aba
    DevIconTs { fg = "#519aba", }, -- DevIconTs      xxx ctermfg=67 guifg=#519aba
    DevIconTsx { fg = "#519aba", }, -- DevIconTsx     xxx ctermfg=67 guifg=#519aba
    DevIconTwig { fg = "#8dc149", }, -- DevIconTwig    xxx ctermfg=107 guifg=#8dc149
    DevIconTxt { fg = "#89e051", }, -- DevIconTxt     xxx ctermfg=113 guifg=#89e051
    DevIconVHDL { fg = "#019833", }, -- DevIconVHDL    xxx ctermfg=29 guifg=#019833
    DevIconVagrantfile { fg = "#1563ff", }, -- DevIconVagrantfile xxx ctermfg=27 guifg=#1563ff
    DevIconVerilog { fg = "#019833", }, -- DevIconVerilog xxx ctermfg=29 guifg=#019833
    DevIconVim { fg = "#019833", }, -- DevIconVim     xxx ctermfg=29 guifg=#019833
    DevIconVimrc { fg = "#019833", }, -- DevIconVimrc   xxx ctermfg=29 guifg=#019833
    DevIconVue { fg = "#8dc149", }, -- DevIconVue     xxx ctermfg=107 guifg=#8dc149
    DevIconWebmanifest { fg = "#f1e05a", }, -- DevIconWebmanifest xxx ctermfg=221 guifg=#f1e05a
    DevIconWebp { fg = "#a074c4", }, -- DevIconWebp    xxx ctermfg=140 guifg=#a074c4
    DevIconWebpack { fg = "#519aba", }, -- DevIconWebpack xxx ctermfg=67 guifg=#519aba
    DevIconXcPlayground { fg = "#e37933", }, -- DevIconXcPlayground xxx ctermfg=173 guifg=#e37933
    DevIconXls { fg = "#207245", }, -- DevIconXls     xxx ctermfg=23 guifg=#207245
    DevIconXml { fg = "#e37933", }, -- DevIconXml     xxx ctermfg=173 guifg=#e37933
    DevIconXul { fg = "#e37933", }, -- DevIconXul     xxx ctermfg=173 guifg=#e37933
    DevIconYaml { fg = "#6d8086", }, -- DevIconYaml    xxx ctermfg=66 guifg=#6d8086
    DevIconYml { fg = "#6d8086", }, -- DevIconYml     xxx ctermfg=66 guifg=#6d8086
    DevIconZig { fg = "#f69a1b", }, -- DevIconZig     xxx ctermfg=208 guifg=#f69a1b
    DevIconZsh { fg = "#89e051", }, -- DevIconZsh     xxx ctermfg=113 guifg=#89e051
    DevIconZshenv { fg = "#89e051", }, -- DevIconZshenv  xxx ctermfg=113 guifg=#89e051
    DevIconZshprofile { fg = "#89e051", }, -- DevIconZshprofile xxx ctermfg=113 guifg=#89e051
    DevIconZshrc { fg = "#89e051", }, -- DevIconZshrc   xxx ctermfg=113 guifg=#89e051
    LineNr { fg = hsl("#c6c6c6") },
  }
end)

lush(spec)
