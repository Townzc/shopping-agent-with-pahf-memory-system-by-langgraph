param(
    [string]$OutputDir = "frontend/public/product-images"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$cwebp = Get-Command cwebp -ErrorAction SilentlyContinue
if (-not $cwebp) {
    throw "cwebp is required to generate WebP product thumbnails."
}

$items = @(
    @{ id = "P1001"; title = "星云 Pro 13 旗舰手机"; category = "数码3C"; icon = "phone"; color = "#2563eb" },
    @{ id = "P1002"; title = "声波 X 主动降噪耳机"; category = "数码3C"; icon = "headphones"; color = "#4f46e5" },
    @{ id = "P1003"; title = "光刃 15 轻薄笔记本"; category = "数码3C"; icon = "laptop"; color = "#0f766e" },
    @{ id = "P1004"; title = "星云 Mini 8.8 平板电脑"; category = "数码3C"; icon = "tablet"; color = "#0284c7" },
    @{ id = "P1005"; title = "清风 27 英寸 4K 显示器"; category = "数码3C"; icon = "monitor"; color = "#0891b2" },
    @{ id = "P1006"; title = "悦写 K3 机械键盘"; category = "数码3C"; icon = "keyboard"; color = "#4338ca" },
    @{ id = "P1007"; title = "Pocket 65W 氮化镓快充头"; category = "数码3C"; icon = "charger"; color = "#0369a1" },
    @{ id = "P1008"; title = "LinkPro AX3000 双频路由器"; category = "数码3C"; icon = "router"; color = "#047857" },
    @{ id = "P1009"; title = "腕上 Pulse S2 智能手表"; category = "数码3C"; icon = "watch"; color = "#7c3aed" },
    @{ id = "P1010"; title = "影巡 2K 家用摄像头"; category = "数码3C"; icon = "camera"; color = "#475569" },

    @{ id = "P2001"; title = "云感纯棉圆领卫衣"; category = "服饰鞋包"; icon = "hoodie"; color = "#64748b" },
    @{ id = "P2002"; title = "全天候轻量冲锋衣"; category = "服饰鞋包"; icon = "jacket"; color = "#16a34a" },
    @{ id = "P2003"; title = "通勤防泼水双肩包 22L"; category = "服饰鞋包"; icon = "backpack"; color = "#334155" },
    @{ id = "P2004"; title = "云弹缓震跑步鞋"; category = "服饰鞋包"; icon = "shoes"; color = "#ea580c" },
    @{ id = "P2005"; title = "抗皱商务衬衫"; category = "服饰鞋包"; icon = "shirt"; color = "#0ea5e9" },
    @{ id = "P2006"; title = "24寸轻量拉杆箱"; category = "服饰鞋包"; icon = "suitcase"; color = "#14b8a6" },
    @{ id = "P2007"; title = "高腰速干瑜伽裤"; category = "服饰鞋包"; icon = "leggings"; color = "#9333ea" },
    @{ id = "P2008"; title = "德绒保暖内衣套装"; category = "服饰鞋包"; icon = "thermal"; color = "#be123c" },

    @{ id = "P3001"; title = "静音人体工学办公椅"; category = "家居日用"; icon = "chair"; color = "#0f766e" },
    @{ id = "P3002"; title = "暖光护眼台灯"; category = "家居日用"; icon = "lamp"; color = "#f59e0b" },
    @{ id = "P3003"; title = "静音人体工学办公椅 Pro"; category = "家居日用"; icon = "chair-pro"; color = "#0d9488" },
    @{ id = "P3004"; title = "透明抽屉式收纳箱 3只装"; category = "家居日用"; icon = "storage"; color = "#38bdf8" },
    @{ id = "P3005"; title = "云柔抗菌四件套"; category = "家居日用"; icon = "bedding"; color = "#60a5fa" },
    @{ id = "P3006"; title = "米白陶瓷不粘煎锅 28cm"; category = "家居日用"; icon = "pan"; color = "#78716c" },
    @{ id = "P3007"; title = "恒温电热水壶 1.7L"; category = "家居日用"; icon = "kettle"; color = "#06b6d4" },
    @{ id = "P3008"; title = "轻音无线吸尘器 V6"; category = "家居日用"; icon = "vacuum"; color = "#2563eb" },
    @{ id = "P3009"; title = "低噪空气净化器 A5"; category = "家居日用"; icon = "purifier"; color = "#22c55e" },
    @{ id = "P3010"; title = "浴室速干毛巾 4条装"; category = "家居日用"; icon = "towels"; color = "#f97316" },

    @{ id = "P4001"; title = "水光保湿精华 30ml"; category = "美妆个护"; icon = "serum"; color = "#ec4899" },
    @{ id = "P4002"; title = "氨基酸温和洁面 120g"; category = "美妆个护"; icon = "cleanser"; color = "#06b6d4" },
    @{ id = "P4003"; title = "清透防晒乳 SPF50+ 50ml"; category = "美妆个护"; icon = "sunscreen"; color = "#f59e0b" },
    @{ id = "P4004"; title = "负离子高速吹风机"; category = "美妆个护"; icon = "hairdryer"; color = "#d946ef" },
    @{ id = "P4005"; title = "玻尿酸补水面膜 20片"; category = "美妆个护"; icon = "mask"; color = "#38bdf8" },
    @{ id = "P4006"; title = "声波电动牙刷 T5"; category = "美妆个护"; icon = "toothbrush"; color = "#0ea5e9" },
    @{ id = "P4007"; title = "三刀头电动剃须刀"; category = "美妆个护"; icon = "shaver"; color = "#334155" },

    @{ id = "P5001"; title = "柔薄拉拉裤 L 码 76片"; category = "母婴宠物"; icon = "diaper"; color = "#fb7185" },
    @{ id = "P5002"; title = "婴儿恒温调奶器 1.2L"; category = "母婴宠物"; icon = "warmer"; color = "#f97316" },
    @{ id = "P5003"; title = "可折叠轻便婴儿推车"; category = "母婴宠物"; icon = "stroller"; color = "#64748b" },
    @{ id = "P5004"; title = "PPSU 宽口奶瓶 240ml"; category = "母婴宠物"; icon = "baby-bottle"; color = "#f59e0b" },
    @{ id = "P5005"; title = "成猫全价猫粮 5kg"; category = "母婴宠物"; icon = "cat-food"; color = "#a16207" },
    @{ id = "P5006"; title = "豆腐猫砂 6L 4包"; category = "母婴宠物"; icon = "cat-litter"; color = "#84cc16" },
    @{ id = "P5007"; title = "宠物自动饮水机 2.5L"; category = "母婴宠物"; icon = "pet-fountain"; color = "#0ea5e9" },

    @{ id = "P6001"; title = "意式拼配咖啡豆 500g"; category = "食品饮料"; icon = "coffee"; color = "#92400e" },
    @{ id = "P6002"; title = "每日坚果 30包"; category = "食品饮料"; icon = "nuts"; color = "#ca8a04" },
    @{ id = "P6003"; title = "低糖燕麦脆 1kg"; category = "食品饮料"; icon = "oatmeal"; color = "#d97706" },
    @{ id = "P6004"; title = "无糖乌龙茶 12瓶"; category = "食品饮料"; icon = "tea"; color = "#15803d" },

    @{ id = "P7001"; title = "加厚防潮露营垫"; category = "运动户外"; icon = "camp-mat"; color = "#16a34a" },
    @{ id = "P7002"; title = "全自动速开帐篷 3-4人"; category = "运动户外"; icon = "tent"; color = "#f97316" },
    @{ id = "P7003"; title = "可调节哑铃 10kg 一对"; category = "运动户外"; icon = "dumbbells"; color = "#475569" },
    @{ id = "P7004"; title = "防滑 TPE 瑜伽垫 6mm"; category = "运动户外"; icon = "yoga-mat"; color = "#8b5cf6" },
    @{ id = "P7005"; title = "一体成型骑行头盔"; category = "运动户外"; icon = "helmet"; color = "#0f172a" },

    @{ id = "P8001"; title = "点阵活页笔记本 A5"; category = "图书文具"; icon = "notebook"; color = "#2563eb" },
    @{ id = "P8002"; title = "0.5mm 速干中性笔 12支"; category = "图书文具"; icon = "pens"; color = "#4f46e5" },
    @{ id = "P8003"; title = "人体工学护腕鼠标垫"; category = "图书文具"; icon = "wrist-rest"; color = "#64748b" },
    @{ id = "P8004"; title = "双层桌面文件架"; category = "图书文具"; icon = "file-rack"; color = "#0891b2" }
)

function ColorFromHex([string]$hex) {
    $h = $hex.TrimStart("#")
    return [System.Drawing.Color]::FromArgb(
        [Convert]::ToInt32($h.Substring(0, 2), 16),
        [Convert]::ToInt32($h.Substring(2, 2), 16),
        [Convert]::ToInt32($h.Substring(4, 2), 16)
    )
}

function New-Brush([string]$hex) {
    return New-Object System.Drawing.SolidBrush (ColorFromHex $hex)
}

function Add-RoundRectPath($path, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
}

function Fill-RoundRect($g, $brush, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    Add-RoundRectPath $path $x $y $w $h $r
    $g.FillPath($brush, $path)
    $path.Dispose()
}

function Draw-RoundRect($g, $pen, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    Add-RoundRectPath $path $x $y $w $h $r
    $g.DrawPath($pen, $path)
    $path.Dispose()
}

function Draw-TextCentered($g, [string]$text, $font, $brush, [float]$x, [float]$y, [float]$w, [float]$h) {
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::Center
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect = New-Object System.Drawing.RectangleF $x, $y, $w, $h
    $g.DrawString($text, $font, $brush, $rect, $fmt)
    $fmt.Dispose()
}

function Draw-Icon($g, [string]$icon, $mainBrush, $accentBrush, $softBrush, $darkPen, $whitePen, $whiteBrush) {
    switch ($icon) {
        "phone" {
            Fill-RoundRect $g $mainBrush 238 138 164 300 28
            Fill-RoundRect $g $whiteBrush 256 166 128 224 14
            $g.FillEllipse($accentBrush, 306, 402, 28, 28)
            $g.FillEllipse($accentBrush, 278, 190, 16, 16)
            $g.FillEllipse($accentBrush, 304, 190, 16, 16)
            $g.FillEllipse($accentBrush, 330, 190, 16, 16)
        }
        "headphones" {
            $g.DrawArc((New-Object System.Drawing.Pen $mainBrush.Color, 28), 200, 150, 240, 210, 200, 140)
            Fill-RoundRect $g $mainBrush 174 276 66 118 24
            Fill-RoundRect $g $mainBrush 400 276 66 118 24
            Fill-RoundRect $g $accentBrush 198 308 30 56 12
            Fill-RoundRect $g $accentBrush 412 308 30 56 12
        }
        "laptop" {
            Fill-RoundRect $g $mainBrush 172 150 296 190 18
            Fill-RoundRect $g $whiteBrush 194 176 252 134 10
            $g.FillRectangle($accentBrush, 140, 348, 360, 42)
            Fill-RoundRect $g $softBrush 214 356 212 16 8
        }
        "tablet" {
            Fill-RoundRect $g $mainBrush 190 126 260 320 28
            Fill-RoundRect $g $whiteBrush 214 160 212 238 12
            $g.FillEllipse($accentBrush, 308, 410, 24, 24)
        }
        "monitor" {
            Fill-RoundRect $g $mainBrush 142 150 356 220 18
            Fill-RoundRect $g $whiteBrush 166 178 308 150 10
            $g.FillRectangle($mainBrush, 296, 370, 48, 46)
            Fill-RoundRect $g $accentBrush 234 414 172 22 10
        }
        "keyboard" {
            Fill-RoundRect $g $mainBrush 132 210 376 154 22
            for ($row = 0; $row -lt 4; $row++) {
                for ($col = 0; $col -lt 9; $col++) {
                    Fill-RoundRect $g $whiteBrush (154 + $col * 38) (232 + $row * 28) 24 16 5
                }
            }
            Fill-RoundRect $g $accentBrush 246 334 150 16 7
        }
        "charger" {
            Fill-RoundRect $g $mainBrush 226 190 188 194 28
            $g.FillRectangle($darkPen.Brush, 266, 150, 20, 50)
            $g.FillRectangle($darkPen.Brush, 354, 150, 20, 50)
            Fill-RoundRect $g $whiteBrush 260 254 120 46 14
            Fill-RoundRect $g $accentBrush 292 318 56 18 8
        }
        "router" {
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 16), 214, 216, 168, 140)
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 16), 426, 216, 472, 140)
            Fill-RoundRect $g $mainBrush 174 244 292 102 24
            for ($i = 0; $i -lt 4; $i++) { $g.FillEllipse($whiteBrush, 226 + $i * 54, 288, 16, 16) }
            $g.DrawArc((New-Object System.Drawing.Pen $accentBrush.Color, 8), 250, 148, 140, 80, 205, 130)
            $g.DrawArc((New-Object System.Drawing.Pen $accentBrush.Color, 8), 282, 178, 76, 44, 205, 130)
        }
        "watch" {
            Fill-RoundRect $g $mainBrush 264 106 112 104 28
            Fill-RoundRect $g $mainBrush 264 374 112 104 28
            Fill-RoundRect $g $mainBrush 226 194 188 198 42
            Fill-RoundRect $g $whiteBrush 252 224 136 136 30
            $g.DrawLine((New-Object System.Drawing.Pen $accentBrush.Color, 9), 320, 244, 320, 300)
            $g.DrawLine((New-Object System.Drawing.Pen $accentBrush.Color, 9), 320, 300, 354, 316)
        }
        "camera" {
            Fill-RoundRect $g $mainBrush 178 206 284 166 26
            Fill-RoundRect $g $accentBrush 212 176 92 42 16
            $g.FillEllipse($whiteBrush, 266, 226, 112, 112)
            $g.FillEllipse($mainBrush, 294, 254, 56, 56)
            $g.FillEllipse($accentBrush, 410, 226, 22, 22)
        }
        "hoodie" {
            $pts = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 248,150),(New-Object System.Drawing.Point 392,150),(New-Object System.Drawing.Point 480,254),(New-Object System.Drawing.Point 430,310),(New-Object System.Drawing.Point 402,274),(New-Object System.Drawing.Point 402,430),(New-Object System.Drawing.Point 238,430),(New-Object System.Drawing.Point 238,274),(New-Object System.Drawing.Point 210,310),(New-Object System.Drawing.Point 160,254))
            $g.FillPolygon($mainBrush, $pts)
            $g.DrawArc((New-Object System.Drawing.Pen $accentBrush.Color, 16), 264, 132, 112, 86, 10, 160)
            $g.DrawLine((New-Object System.Drawing.Pen $whiteBrush.Color, 5), 320, 178, 320, 310)
        }
        "jacket" {
            $pts = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 220,146),(New-Object System.Drawing.Point 420,146),(New-Object System.Drawing.Point 492,266),(New-Object System.Drawing.Point 440,314),(New-Object System.Drawing.Point 404,258),(New-Object System.Drawing.Point 404,434),(New-Object System.Drawing.Point 236,434),(New-Object System.Drawing.Point 236,258),(New-Object System.Drawing.Point 200,314),(New-Object System.Drawing.Point 148,266))
            $g.FillPolygon($mainBrush, $pts)
            $g.DrawLine((New-Object System.Drawing.Pen $whiteBrush.Color, 8), 320, 154, 320, 430)
            $g.DrawLine((New-Object System.Drawing.Pen $accentBrush.Color, 6), 256, 214, 294, 260)
            $g.DrawLine((New-Object System.Drawing.Pen $accentBrush.Color, 6), 384, 214, 346, 260)
        }
        "chair" {
            Fill-RoundRect $g $mainBrush 236 130 168 190 34
            Fill-RoundRect $g $accentBrush 208 318 224 74 28
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 14), 320, 390, 320, 456)
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 12), 320, 456, 246, 486)
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 12), 320, 456, 394, 486)
            $g.FillEllipse($darkPen.Brush, 236, 478, 28, 28)
            $g.FillEllipse($darkPen.Brush, 376, 478, 28, 28)
        }
        "chair-pro" {
            Fill-RoundRect $g $accentBrush 266 94 108 58 22
            Fill-RoundRect $g $mainBrush 226 148 188 202 38
            Fill-RoundRect $g $accentBrush 200 348 240 70 28
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 14), 320, 418, 320, 474)
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 12), 320, 474, 236, 504)
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 12), 320, 474, 404, 504)
            $g.FillEllipse($darkPen.Brush, 226, 496, 28, 28)
            $g.FillEllipse($darkPen.Brush, 386, 496, 28, 28)
        }
        "lamp" {
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 18), 268, 330, 342, 210)
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 18), 342, 210, 420, 260)
            $shade = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 384,226),(New-Object System.Drawing.Point 506,260),(New-Object System.Drawing.Point 454,330),(New-Object System.Drawing.Point 360,290))
            $g.FillPolygon($mainBrush, $shade)
            $g.FillEllipse($accentBrush, 238, 314, 54, 54)
            Fill-RoundRect $g $mainBrush 214 440 212 34 16
            $g.FillEllipse($softBrush, 344, 302, 164, 92)
        }
        "serum" {
            Fill-RoundRect $g $mainBrush 266 198 108 224 20
            Fill-RoundRect $g $accentBrush 286 148 68 64 14
            $g.FillRectangle($darkPen.Brush, 300, 116, 40, 40)
            Fill-RoundRect $g $whiteBrush 290 268 60 86 16
            $g.FillEllipse($accentBrush, 310, 292, 20, 28)
        }
        "cleanser" {
            $pts = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 256,146),(New-Object System.Drawing.Point 384,146),(New-Object System.Drawing.Point 416,424),(New-Object System.Drawing.Point 224,424))
            $g.FillPolygon($mainBrush, $pts)
            Fill-RoundRect $g $accentBrush 268 118 104 36 10
            Fill-RoundRect $g $whiteBrush 264 248 112 72 18
        }
        "storage" {
            for ($i = 0; $i -lt 3; $i++) {
                Fill-RoundRect $g $softBrush 188 (166 + $i * 86) 264 72 16
                Draw-RoundRect $g $darkPen 188 (166 + $i * 86) 264 72 16
                Fill-RoundRect $g $accentBrush 282 (192 + $i * 86) 76 12 6
            }
        }
        "bedding" {
            Fill-RoundRect $g $mainBrush 154 250 332 160 30
            Fill-RoundRect $g $whiteBrush 180 188 126 76 22
            Fill-RoundRect $g $whiteBrush 334 188 126 76 22
            $g.FillRectangle($accentBrush, 154, 298, 332, 36)
        }
        "pan" {
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 28), 388, 292, 512, 216)
            $g.FillEllipse($mainBrush, 150, 210, 268, 186)
            $g.FillEllipse($softBrush, 182, 238, 204, 130)
        }
        "kettle" {
            Fill-RoundRect $g $mainBrush 244 210 174 190 44
            $g.DrawArc((New-Object System.Drawing.Pen $mainBrush.Color, 16), 380, 236, 90, 110, 270, 180)
            $pts = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 238,250),(New-Object System.Drawing.Point 174,272),(New-Object System.Drawing.Point 238,304))
            $g.FillPolygon($mainBrush, $pts)
            Fill-RoundRect $g $accentBrush 270 156 118 58 20
            $g.FillRectangle($darkPen.Brush, 294, 128, 72, 30)
        }
        "vacuum" {
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 18), 240, 146, 366, 374)
            Fill-RoundRect $g $accentBrush 204 120 88 70 26
            Fill-RoundRect $g $mainBrush 330 340 90 92 24
            Fill-RoundRect $g $darkPen.Brush 274 430 208 34 16
        }
        "purifier" {
            Fill-RoundRect $g $mainBrush 226 132 188 306 34
            Fill-RoundRect $g $whiteBrush 254 164 132 46 16
            for ($row = 0; $row -lt 4; $row++) {
                for ($col = 0; $col -lt 3; $col++) {
                    $g.FillEllipse($accentBrush, 266 + $col * 46, 258 + $row * 36, 18, 18)
                }
            }
        }
        "towels" {
            Fill-RoundRect $g $mainBrush 172 292 296 60 18
            Fill-RoundRect $g $accentBrush 188 238 264 58 18
            Fill-RoundRect $g $softBrush 204 184 232 58 18
            $g.DrawArc((New-Object System.Drawing.Pen $mainBrush.Color, 16), 214, 350, 212, 82, 0, 180)
        }
        "backpack" {
            Fill-RoundRect $g $mainBrush 220 168 200 264 42
            Fill-RoundRect $g $accentBrush 260 242 120 98 24
            $g.DrawArc((New-Object System.Drawing.Pen $darkPen.Color, 12), 244, 116, 152, 128, 210, 120)
            $g.DrawLine($whitePen, 320, 168, 320, 432)
        }
        "shoes" {
            $left = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 160,320),(New-Object System.Drawing.Point 282,278),(New-Object System.Drawing.Point 364,330),(New-Object System.Drawing.Point 360,374),(New-Object System.Drawing.Point 154,374))
            $right = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 266,254),(New-Object System.Drawing.Point 406,230),(New-Object System.Drawing.Point 486,300),(New-Object System.Drawing.Point 474,344),(New-Object System.Drawing.Point 278,334))
            $g.FillPolygon($mainBrush, $left)
            $g.FillPolygon($accentBrush, $right)
            $g.DrawLine($whitePen, 232, 322, 314, 322)
            $g.DrawLine($whitePen, 340, 276, 420, 288)
        }
        "shirt" {
            $pts = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 230,150),(New-Object System.Drawing.Point 410,150),(New-Object System.Drawing.Point 494,242),(New-Object System.Drawing.Point 442,302),(New-Object System.Drawing.Point 402,260),(New-Object System.Drawing.Point 402,430),(New-Object System.Drawing.Point 238,430),(New-Object System.Drawing.Point 238,260),(New-Object System.Drawing.Point 198,302),(New-Object System.Drawing.Point 146,242))
            $g.FillPolygon($mainBrush, $pts)
            $g.DrawLine($whitePen, 320, 152, 320, 430)
            $g.DrawLine((New-Object System.Drawing.Pen $accentBrush.Color, 7), 286, 174, 320, 216)
            $g.DrawLine((New-Object System.Drawing.Pen $accentBrush.Color, 7), 354, 174, 320, 216)
        }
        "suitcase" {
            $g.DrawArc((New-Object System.Drawing.Pen $mainBrush.Color, 12), 268, 106, 104, 80, 180, 180)
            Fill-RoundRect $g $mainBrush 220 174 200 266 28
            $g.DrawLine($whitePen, 268, 202, 268, 410)
            $g.DrawLine($whitePen, 372, 202, 372, 410)
            $g.FillEllipse($darkPen.Brush, 242, 440, 28, 28)
            $g.FillEllipse($darkPen.Brush, 370, 440, 28, 28)
        }
        "leggings" {
            $pts = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 246,142),(New-Object System.Drawing.Point 326,142),(New-Object System.Drawing.Point 306,430),(New-Object System.Drawing.Point 224,430))
            $pts2 = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 326,142),(New-Object System.Drawing.Point 394,142),(New-Object System.Drawing.Point 432,430),(New-Object System.Drawing.Point 346,430))
            $g.FillPolygon($mainBrush, $pts)
            $g.FillPolygon($accentBrush, $pts2)
            Fill-RoundRect $g $darkPen.Brush 236 124 166 38 12
        }
        "thermal" {
            Fill-RoundRect $g $mainBrush 178 168 138 220 28
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 28), 194, 190, 126, 302)
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 28), 300, 190, 368, 302)
            $pts = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 374,184),(New-Object System.Drawing.Point 454,184),(New-Object System.Drawing.Point 438,430),(New-Object System.Drawing.Point 358,430))
            $pts2 = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 454,184),(New-Object System.Drawing.Point 512,184),(New-Object System.Drawing.Point 532,430),(New-Object System.Drawing.Point 454,430))
            $g.FillPolygon($accentBrush, $pts)
            $g.FillPolygon($mainBrush, $pts2)
        }
        "sunscreen" {
            $pts = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 248,168),(New-Object System.Drawing.Point 392,168),(New-Object System.Drawing.Point 420,424),(New-Object System.Drawing.Point 220,424))
            $g.FillPolygon($mainBrush, $pts)
            Fill-RoundRect $g $whiteBrush 264 248 112 72 18
            $g.DrawEllipse((New-Object System.Drawing.Pen $accentBrush.Color, 10), 410, 126, 70, 70)
            for ($i=0; $i -lt 8; $i++) {
                $a = $i * [Math]::PI / 4
                $x1 = 445 + [Math]::Cos($a) * 48
                $y1 = 161 + [Math]::Sin($a) * 48
                $x2 = 445 + [Math]::Cos($a) * 70
                $y2 = 161 + [Math]::Sin($a) * 70
                $g.DrawLine((New-Object System.Drawing.Pen $accentBrush.Color, 5), [float]$x1, [float]$y1, [float]$x2, [float]$y2)
            }
        }
        "hairdryer" {
            Fill-RoundRect $g $mainBrush 198 188 224 108 46
            $pts = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 408,210),(New-Object System.Drawing.Point 506,230),(New-Object System.Drawing.Point 408,266))
            $g.FillPolygon($mainBrush, $pts)
            Fill-RoundRect $g $accentBrush 284 286 66 150 20
            $g.DrawLine($whitePen, 228, 240, 384, 240)
        }
        "mask" {
            Fill-RoundRect $g $mainBrush 204 164 232 274 24
            for ($i=0; $i -lt 4; $i++) {
                Fill-RoundRect $g $whiteBrush (238 + $i*18) (202 + $i*34) 154 54 12
            }
            Fill-RoundRect $g $accentBrush 262 356 116 34 12
        }
        "toothbrush" {
            Fill-RoundRect $g $mainBrush 286 172 68 272 30
            Fill-RoundRect $g $accentBrush 270 118 100 70 22
            for ($i=0; $i -lt 4; $i++) { $g.DrawLine($whitePen, 286 + $i*18, 132, 286 + $i*18, 174) }
            $g.FillEllipse($whiteBrush, 310, 322, 20, 20)
        }
        "shaver" {
            Fill-RoundRect $g $mainBrush 234 180 172 252 50
            Fill-RoundRect $g $accentBrush 248 126 144 82 26
            for ($i=0; $i -lt 3; $i++) { $g.FillEllipse($whiteBrush, 264 + $i*42, 144, 30, 46) }
            $g.FillEllipse($whiteBrush, 302, 300, 36, 36)
        }
        "diaper" {
            Fill-RoundRect $g $mainBrush 194 182 252 238 42
            $g.FillEllipse($whiteBrush, 250, 238, 140, 118)
            $g.DrawArc((New-Object System.Drawing.Pen $accentBrush.Color, 12), 230, 196, 180, 190, 30, 120)
        }
        "warmer" {
            Fill-RoundRect $g $mainBrush 216 230 208 188 34
            Fill-RoundRect $g $accentBrush 270 126 100 128 24
            Fill-RoundRect $g $whiteBrush 292 154 56 72 14
            $g.FillEllipse($whiteBrush, 296, 330, 48, 48)
        }
        "stroller" {
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 12), 214, 180, 366, 338)
            Fill-RoundRect $g $mainBrush 236 220 166 116 38
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 12), 262, 330, 220, 414)
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 12), 382, 330, 432, 414)
            $g.FillEllipse($accentBrush, 192, 400, 52, 52)
            $g.FillEllipse($accentBrush, 410, 400, 52, 52)
        }
        "baby-bottle" {
            Fill-RoundRect $g $mainBrush 262 194 116 242 28
            Fill-RoundRect $g $accentBrush 282 150 76 58 18
            $g.FillPolygon($accentBrush, [System.Drawing.Point[]]@((New-Object System.Drawing.Point 300,120),(New-Object System.Drawing.Point 340,120),(New-Object System.Drawing.Point 358,150),(New-Object System.Drawing.Point 282,150)))
            for ($i=0; $i -lt 4; $i++) { $g.DrawLine($whitePen, 286, 250 + $i*38, 354, 250 + $i*38) }
        }
        "cat-food" {
            Fill-RoundRect $g $mainBrush 226 146 188 292 26
            Fill-RoundRect $g $whiteBrush 262 234 116 92 20
            $g.FillEllipse($accentBrush, 296, 264, 48, 40)
            for ($i=0; $i -lt 4; $i++) { $g.FillEllipse($accentBrush, 280 + $i*26, 244, 18, 18) }
        }
        "cat-litter" {
            Fill-RoundRect $g $mainBrush 190 182 120 222 24
            Fill-RoundRect $g $accentBrush 330 182 120 222 24
            for ($i=0; $i -lt 18; $i++) { $g.FillEllipse($whiteBrush, 224 + ($i % 6)*32, 428 + [Math]::Floor($i/6)*18, 16, 12) }
        }
        "pet-fountain" {
            Fill-RoundRect $g $mainBrush 232 238 176 142 34
            $g.FillEllipse($accentBrush, 206, 334, 228, 78)
            $g.DrawArc((New-Object System.Drawing.Pen $whiteBrush.Color, 10), 276, 144, 88, 114, 200, 140)
            $g.DrawLine($whitePen, 320, 250, 320, 310)
        }
        "coffee" {
            Fill-RoundRect $g $mainBrush 228 146 184 288 32
            Fill-RoundRect $g $accentBrush 260 204 120 72 20
            for ($i=0; $i -lt 5; $i++) { $g.FillEllipse($darkPen.Brush, 190 + $i*58, 444, 32, 44) }
        }
        "nuts" {
            Fill-RoundRect $g $mainBrush 170 198 118 190 24
            Fill-RoundRect $g $accentBrush 318 198 118 190 24
            for ($i=0; $i -lt 8; $i++) { $g.FillEllipse($whiteBrush, 190 + ($i%4)*60, 410 + [Math]::Floor($i/4)*34, 36, 26) }
        }
        "oatmeal" {
            Fill-RoundRect $g $mainBrush 234 146 172 244 26
            $g.FillEllipse($accentBrush, 192, 348, 256, 82)
            $g.FillEllipse($whiteBrush, 216, 330, 208, 82)
            for ($i=0; $i -lt 10; $i++) { $g.FillEllipse($mainBrush, 236 + ($i%5)*34, 352 + [Math]::Floor($i/5)*24, 18, 14) }
        }
        "tea" {
            for ($i=0; $i -lt 4; $i++) {
                Fill-RoundRect $g $mainBrush (190 + $i*66) 172 44 218 16
                Fill-RoundRect $g $accentBrush (196 + $i*66) 132 32 50 10
                Fill-RoundRect $g $whiteBrush (198 + $i*66) 246 28 64 10
            }
            Fill-RoundRect $g $accentBrush 164 400 312 36 16
        }
        "camp-mat" {
            Fill-RoundRect $g $mainBrush 172 312 296 72 28
            $g.FillEllipse($accentBrush, 152, 298, 96, 98)
            $g.FillEllipse($whiteBrush, 178, 322, 44, 48)
            $g.DrawLine($whitePen, 244, 348, 452, 348)
        }
        "tent" {
            $tent = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 160,406),(New-Object System.Drawing.Point 320,150),(New-Object System.Drawing.Point 480,406))
            $g.FillPolygon($mainBrush, $tent)
            $door = [System.Drawing.Point[]]@((New-Object System.Drawing.Point 286,406),(New-Object System.Drawing.Point 320,254),(New-Object System.Drawing.Point 354,406))
            $g.FillPolygon($accentBrush, $door)
            $g.DrawLine($whitePen, 320, 150, 320, 406)
        }
        "dumbbells" {
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 28), 184, 292, 456, 292)
            Fill-RoundRect $g $accentBrush 134 232 58 120 16
            Fill-RoundRect $g $accentBrush 200 244 42 96 14
            Fill-RoundRect $g $accentBrush 398 244 42 96 14
            Fill-RoundRect $g $accentBrush 448 232 58 120 16
        }
        "yoga-mat" {
            Fill-RoundRect $g $mainBrush 154 326 332 70 28
            $g.FillEllipse($accentBrush, 422, 302, 90, 116)
            $g.FillEllipse($whiteBrush, 448, 332, 38, 56)
            $g.DrawLine($whitePen, 180, 360, 422, 360)
        }
        "helmet" {
            $g.FillPie($mainBrush, 174, 172, 292, 230, 180, 180)
            Fill-RoundRect $g $mainBrush 174 282 292 78 22
            Fill-RoundRect $g $accentBrush 252 210 136 52 20
            $g.DrawArc($whitePen, 226, 206, 188, 116, 190, 160)
        }
        "notebook" {
            Fill-RoundRect $g $mainBrush 210 132 220 308 24
            Fill-RoundRect $g $whiteBrush 246 156 160 260 12
            for ($i=0; $i -lt 8; $i++) { $g.FillEllipse($accentBrush, 222, 178 + $i*28, 14, 14) }
            for ($i=0; $i -lt 6; $i++) { $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 3), 270, 210 + $i*30, 388, 210 + $i*30) }
        }
        "pens" {
            for ($i=0; $i -lt 4; $i++) {
                $x = 214 + $i*58
                Fill-RoundRect $g $mainBrush $x 154 34 256 14
                $g.FillPolygon($accentBrush, [System.Drawing.Point[]]@((New-Object System.Drawing.Point $x,410),(New-Object System.Drawing.Point ($x+34),410),(New-Object System.Drawing.Point ($x+17),456)))
                $g.FillRectangle($whiteBrush, $x, 204, 34, 22)
            }
        }
        "wrist-rest" {
            Fill-RoundRect $g $mainBrush 164 230 312 190 34
            Fill-RoundRect $g $accentBrush 188 348 264 46 22
            Fill-RoundRect $g $whiteBrush 286 258 98 72 30
            $g.DrawLine((New-Object System.Drawing.Pen $mainBrush.Color, 5), 335, 264, 335, 326)
        }
        "file-rack" {
            for ($i=0; $i -lt 2; $i++) {
                $y = 238 + $i*86
                Fill-RoundRect $g $mainBrush 182 $y 276 58 16
                $g.DrawLine($whitePen, 210, ($y+18), 430, ($y+18))
            }
            $g.DrawLine((New-Object System.Drawing.Pen $accentBrush.Color, 16), 190, 206, 190, 410)
            $g.DrawLine((New-Object System.Drawing.Pen $accentBrush.Color, 16), 450, 206, 450, 410)
            for ($i=0; $i -lt 3; $i++) {
                $g.FillPolygon($whiteBrush, [System.Drawing.Point[]]@((New-Object System.Drawing.Point (226 + $i*54),170),(New-Object System.Drawing.Point (266 + $i*54),170),(New-Object System.Drawing.Point (278 + $i*54),230),(New-Object System.Drawing.Point (214 + $i*54),230)))
            }
        }
        default {
            Fill-RoundRect $g $mainBrush 200 178 240 240 42
            $g.FillEllipse($accentBrush, 260, 238, 120, 120)
        }
    }
}

function Save-ProductImage($item, [string]$dir) {
    $width = 640
    $height = 640
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $main = ColorFromHex $item.color
    $soft = [System.Drawing.Color]::FromArgb(42, $main.R, $main.G, $main.B)
    $accent = [System.Drawing.Color]::FromArgb(
        [Math]::Min(255, [int]($main.R * 0.72 + 80)),
        [Math]::Min(255, [int]($main.G * 0.72 + 70)),
        [Math]::Min(255, [int]($main.B * 0.72 + 45))
    )
    $bgTop = [System.Drawing.Color]::FromArgb(250, 252, 255)
    $bgBottom = [System.Drawing.Color]::FromArgb(232, 238, 246)
    $rect = New-Object System.Drawing.Rectangle 0, 0, $width, $height
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, $bgTop, $bgBottom, 90
    $g.FillRectangle($bg, $rect)

    $mainBrush = New-Object System.Drawing.SolidBrush $main
    $accentBrush = New-Object System.Drawing.SolidBrush $accent
    $softBrush = New-Object System.Drawing.SolidBrush $soft
    $darkBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(36, 45, 58))
    $whiteBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255))
    $mutedBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(90, 103, 121))
    $darkPen = New-Object System.Drawing.Pen $darkBrush.Color, 4
    $whitePen = New-Object System.Drawing.Pen $whiteBrush.Color, 6

    $shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(22, 15, 23, 42))
    $g.FillEllipse($shadow, 144, 432, 352, 46)
    $g.FillEllipse($softBrush, 92, 74, 456, 456)

    Draw-Icon $g $item.icon $mainBrush $accentBrush $softBrush $darkPen $whitePen $whiteBrush

    $titleFont = New-Object System.Drawing.Font "Microsoft YaHei UI", 24, ([System.Drawing.FontStyle]::Bold)
    $metaFont = New-Object System.Drawing.Font "Microsoft YaHei UI", 14, ([System.Drawing.FontStyle]::Regular)
    $idFont = New-Object System.Drawing.Font "Segoe UI", 13, ([System.Drawing.FontStyle]::Bold)
    Draw-TextCentered $g $item.title $titleFont $darkBrush 58 500 524 50
    Draw-TextCentered $g $item.category $metaFont $mutedBrush 58 548 524 30
    Fill-RoundRect $g $whiteBrush 34 32 86 34 17
    Draw-TextCentered $g $item.id $idFont $mutedBrush 34 32 86 34

    $png = Join-Path ([System.IO.Path]::GetTempPath()) "$($item.id)-product.png"
    $webp = Join-Path $dir "$($item.id).webp"
    $bmp.Save($png, [System.Drawing.Imaging.ImageFormat]::Png)

    $g.Dispose()
    $bmp.Dispose()
    foreach ($obj in @($bg, $mainBrush, $accentBrush, $softBrush, $darkBrush, $whiteBrush, $mutedBrush, $darkPen, $whitePen, $shadow, $titleFont, $metaFont, $idFont)) {
        if ($obj) { $obj.Dispose() }
    }

    & $cwebp.Source -quiet -q 88 $png -o $webp
    Remove-Item -LiteralPath $png -Force
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$target = Join-Path $repoRoot $OutputDir
New-Item -ItemType Directory -Force -Path $target | Out-Null

foreach ($item in $items) {
    Save-ProductImage $item $target
}

$manifest = $items | ForEach-Object {
    [ordered]@{
        product_id = $_.id
        title = $_.title
        category = $_.category
        image = "/product-images/$($_.id).webp"
        source = "generated-product-illustration"
        note = "Deterministic local illustration generated by scripts/generate-product-images.ps1 to keep product image and title aligned."
    }
}
$manifestPath = Join-Path $target "source-manifest.json"
$manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Write-Host "Generated $($items.Count) product images in $target"
