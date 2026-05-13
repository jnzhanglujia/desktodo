#requires -Version 5.0
<#
.SYNOPSIS
  桌面待办事项 Widget — 始终停留在 Windows 桌面上
.DESCRIPTION
  半透明暗色无边框窗口，始终置顶，支持添加/完成/删除待办，
  自动保存到 todo-data.json，双击 启动待办.bat 即可运行。
#>

# 错误处理：如果出错，弹出提示框
trap {
  [System.Windows.MessageBox]::Show("发生错误：$_`n$($_.ScriptStackTrace)", "桌面待办", "OK", "Error")
  exit 1
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$dataFile = Join-Path $scriptDir "todo-data.json"

# ===== 工具函数 =====
function Brush($hex) {
  [System.Windows.Media.BrushConverter]::new().ConvertFromString($hex)
}

# ===== 数据层 =====
$tasks = [System.Collections.ObjectModel.ObservableCollection[PSObject]]::new()
$settings = @{ Top = 100; Left = -1; Topmost = $true }

function Load-Data {
  if (-not (Test-Path $dataFile)) {
    Add-SampleTasks
    return
  }
  try {
    $json = Get-Content $dataFile -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($json.tasks) {
      $tasks.Clear()
      foreach ($item in $json.tasks) {
        $tasks.Add([PSCustomObject]@{
          Id        = if ($item.Id) { $item.Id } else { [Guid]::NewGuid().ToString() }
          Text      = $item.Text
          IsDone    = [bool]$item.IsDone
          CreatedAt = if ($item.CreatedAt) { $item.CreatedAt } else { (Get-Date).ToString("yyyy-MM-dd HH:mm") }
        })
      }
    }
    if ($json.settings) {
      $settings.Top     = if ($json.settings.Top -ne $null)    { $json.settings.Top }     else { 100 }
      $settings.Left    = if ($json.settings.Left -ne $null)   { $json.settings.Left }    else { -1 }
      $settings.Topmost = if ($json.settings.Topmost -ne $null) { [bool]$json.settings.Topmost } else { $true }
    }
  } catch {
    Add-SampleTasks
  }
  if ($tasks.Count -eq 0) { Add-SampleTasks }
}

function Add-SampleTasks {
  $tasks.Add([PSCustomObject]@{ Id = [Guid]::NewGuid().ToString(); Text = "欢迎使用桌面待办！";           IsDone = $false; CreatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm") })
  $tasks.Add([PSCustomObject]@{ Id = [Guid]::NewGuid().ToString(); Text = "点击 □ 标记已完成";           IsDone = $false; CreatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm") })
  $tasks.Add([PSCustomObject]@{ Id = [Guid]::NewGuid().ToString(); Text = "点击 🗑 删除任务";            IsDone = $false; CreatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm") })
  $tasks.Add([PSCustomObject]@{ Id = [Guid]::NewGuid().ToString(); Text = "按 Enter 快速添加新任务";     IsDone = $false; CreatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm") })
}

function Save-Data {
  $data = @{
    tasks    = @($tasks | ForEach-Object { @{ Id = $_.Id; Text = $_.Text; IsDone = $_.IsDone; CreatedAt = $_.CreatedAt } })
    settings = @{ Top = [int]$window.Top; Left = [int]$window.Left; Topmost = [bool]$window.Topmost }
  }
  $data | ConvertTo-Json -Compress | Set-Content $dataFile -Encoding UTF8
}

# ===== 渲染任务列表 =====
function Update-TaskList {
  $taskPanel.Children.Clear()
  if ($tasks.Count -eq 0) {
    $emptyText = New-Object System.Windows.Controls.TextBlock -Property @{
      Text               = "还没有任务 ✨`n输入新任务开始吧"
      Foreground         = Brush("#585B70")
      FontSize           = 13
      HorizontalAlignment = "Center"
      Margin             = [System.Windows.Thickness]::new(0, 24, 0, 24)
    }
    $taskPanel.Children.Add($emptyText) | Out-Null
    return
  }
  foreach ($task in $tasks) {
    # 外层 Border
    $border = New-Object System.Windows.Controls.Border -Property @{
      Margin        = [System.Windows.Thickness]::new(0, 2, 0, 2)
      Padding       = [System.Windows.Thickness]::new(8, 7, 8, 7)
      CornerRadius  = [System.Windows.CornerRadius]::new(6)
      Background    = Brush("#1E1E2E")
      BorderBrush   = Brush("#313244")
      BorderThickness = [System.Windows.Thickness]::new(1)
    }
    # 内部 Grid
    $grid = New-Object System.Windows.Controls.Grid
    $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = "Auto" }))
    $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = "*" }))
    $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = "Auto" }))
    # CheckBox
    $cb = New-Object System.Windows.Controls.CheckBox -Property @{
      IsChecked        = $task.IsDone
      VerticalAlignment = "Center"
      Margin           = [System.Windows.Thickness]::new(0, 0, 8, 0)
      Foreground       = Brush("#A6E3A1")
    }
    [System.Windows.Controls.Grid]::SetColumn($cb, 0)
    # 文本
    $tb = New-Object System.Windows.Controls.TextBlock -Property @{
      Text              = $task.Text
      FontSize          = 13
      VerticalAlignment = "Center"
      TextWrapping      = "Wrap"
    }
    if ($task.IsDone) {
      $tb.Foreground       = Brush("#585B70")
      $tb.TextDecorations  = [System.Windows.TextDecorations]::Strikethrough
    } else {
      $tb.Foreground = Brush("#CDD6F4")
    }
    [System.Windows.Controls.Grid]::SetColumn($tb, 1)
    # 删除按钮
    $delBtn = New-Object System.Windows.Controls.Button -Property @{
      Content       = "🗑"
      Width         = 22; Height = 22
      Background    = [System.Windows.Media.Brushes]::Transparent
      BorderThickness = [System.Windows.Thickness]::new(0)
      Foreground    = Brush("#585B70")
      FontSize      = 11
      Cursor        = [System.Windows.Input.Cursors]::Hand
      ToolTip       = "删除"
    }
    [System.Windows.Controls.Grid]::SetColumn($delBtn, 2)
    # 用 Tag 存储任务引用，避免闭包作用域问题
    $cb.Tag    = $task
    $delBtn.Tag = $task
    $cb.Add_Checked(   { $this.Tag.IsDone = $true;  Update-TaskList; Save-Data })
    $cb.Add_Unchecked( { $this.Tag.IsDone = $false; Update-TaskList; Save-Data })
    $delBtn.Add_Click({
      $tasks.Remove($this.Tag)
      Update-TaskList
      Save-Data
    })
    $grid.Children.Add($cb)     | Out-Null
    $grid.Children.Add($tb)     | Out-Null
    $grid.Children.Add($delBtn) | Out-Null
    $border.Child = $grid
    $taskPanel.Children.Add($border) | Out-Null
  }
}

# ===== 添加任务 =====
function Add-Task {
  $text = $taskInput.Text.Trim()
  if ($text -eq "") { return }
  $tasks.Add([PSCustomObject]@{
    Id        = [Guid]::NewGuid().ToString()
    Text      = $text
    IsDone    = $false
    CreatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm")
  })
  $taskInput.Clear()
  Update-TaskList
  Save-Data
  $taskInput.Focus()
}

# ===== 从剪贴板导入（从 MS To Do 复制后直接粘贴） =====
function Import-FromClipboard {
  $text = [System.Windows.Forms.Clipboard]::GetText()
  if ([string]::IsNullOrEmpty($text)) {
    [System.Windows.MessageBox]::Show("剪贴板为空，请先在 Microsoft To Do 中复制任务（Ctrl+A → Ctrl+C）", "导入", "OK", "Information")
    return
  }
  $count = 0
  foreach ($line in $text.Split(@("`r`n", "`n", "`r"), [StringSplitOptions]::RemoveEmptyEntries)) {
    $line = $line.Trim()
    if ($line -eq "" -or $line.StartsWith("-") -or $line.StartsWith("#")) { continue }
    $exists = $false
    foreach ($t in $tasks) { if ($t.Text -eq $line) { $exists = $true; break } }
    if (-not $exists) {
      $tasks.Add([PSCustomObject]@{ Id = [Guid]::NewGuid().ToString(); Text = $line; IsDone = $false; CreatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm") })
      $count++
    }
  }
  if ($count -gt 0) { Save-Data; Update-TaskList }
  [System.Windows.MessageBox]::Show("已导入 $count 条新任务", "剪贴板导入")
}

# ===== 从 JSON 文件导入 =====
function Import-FromJsonFile {
  $dialog = New-Object Microsoft.Win32.OpenFileDialog -Property @{
    Title = "选择待办 JSON 文件"
    Filter = "JSON 文件 (*.json)|*.json|所有文件 (*.*)|*.*"
  }
  if ($dialog.ShowDialog() -ne $true) { return }
  try {
    $json = Get-Content $dialog.FileName -Raw -Encoding UTF8 | ConvertFrom-Json
    $count = 0
    $items = if ($json -is [array]) { $json } elseif ($json.tasks) { $json.tasks } else { @($json) }
    foreach ($item in $items) {
      $text = if ($item.title) { $item.title } elseif ($item.Text) { $item.Text } elseif ($item -is [string]) { $item } else { continue }
      $done = if ($item.status -eq "completed" -or $item.IsDone) { $true } else { $false }
      $exists = $false
      foreach ($t in $tasks) { if ($t.Text -eq $text) { $exists = $true; break } }
      if (-not $exists) {
        $tasks.Add([PSCustomObject]@{ Id = [Guid]::NewGuid().ToString(); Text = $text; IsDone = $done; CreatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm") })
        $count++
      }
    }
    if ($count -gt 0) { Save-Data; Update-TaskList }
    [System.Windows.MessageBox]::Show("已导入 $count 条新任务", "JSON 导入")
  } catch {
    [System.Windows.MessageBox]::Show("导入失败: $_", "错误", "OK", "Error")
  }
}

# ===== XAML 布局 =====
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="桌面待办" Width="300" SizeToContent="Height"
        WindowStartupLocation="Manual" Top="100" Left="100"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        Topmost="True" ShowInTaskbar="False" ResizeMode="NoResize"
        MinHeight="200" MaxHeight="600">
  <Border CornerRadius="12" Background="#1E1E2E" Opacity="0.94"
          BorderBrush="#313244" BorderThickness="1" Padding="0">
    <Grid>
      <Grid.RowDefinitions>
        <RowDefinition Height="42"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="48"/>
      </Grid.RowDefinitions>

      <!-- ===== 标题栏 ===== -->
      <Grid Grid.Row="0" Background="#181825">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <TextBlock Grid.Column="0" Text="  📋 待办" FontSize="14" Foreground="#CDD6F4"
                   FontWeight="SemiBold" VerticalAlignment="Center"/>
        <Button Grid.Column="1" Name="PinBtn" Content="📌" Width="28" Height="28"
                Background="Transparent" BorderThickness="0"
                Foreground="#F9E2AF" FontSize="12" Cursor="Hand" ToolTip="切换置顶"/>
        <Button Grid.Column="2" Name="CloseBtn" Content="✕" Width="28" Height="28"
                Background="Transparent" BorderThickness="0"
                Foreground="#585B70" FontSize="14" Cursor="Hand"
                ToolTip="关闭" Margin="0,0,4,0"/>
      </Grid>

      <!-- ===== 任务列表 ===== -->
      <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto"
                    Background="Transparent" BorderThickness="0"
                    Padding="8,4">
        <StackPanel Name="TaskPanel" Background="Transparent" MinHeight="60"/>
      </ScrollViewer>

      <!-- ===== 输入区域 ===== -->
      <Border Grid.Row="2" Background="#181825" Padding="8,6"
              CornerRadius="0,0,12,12">
        <Grid>
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <TextBox Name="TaskInput" Grid.Column="0"
                   FontSize="13" Foreground="#CDD6F4"
                   Background="#313244" BorderThickness="0"
                   Padding="8,4" Height="32"
                   VerticalContentAlignment="Center"/>
          <Button Name="AddBtn" Grid.Column="1" Content="＋" Width="32" Height="32"
                  Background="#A6E3A1" BorderThickness="0"
                  Foreground="#1E1E2E" FontSize="16" FontWeight="Bold"
                  Margin="6,0,0,0" Cursor="Hand"/>
          <Button Name="ImportBtn" Grid.Column="2" Content="📥" Width="28" Height="28"
                  Background="Transparent" BorderThickness="0"
                  Foreground="#585B70" FontSize="13" Cursor="Hand"
                  Margin="4,0,0,0" ToolTip="导入任务"/>
        </Grid>
      </Border>
    </Grid>
  </Border>
</Window>
'@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader] $xaml.OuterXml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# ===== 获取控件引用 =====
$taskPanel = $window.FindName("TaskPanel")
$taskInput = $window.FindName("TaskInput")
$addBtn    = $window.FindName("AddBtn")
$pinBtn    = $window.FindName("PinBtn")
$closeBtn  = $window.FindName("CloseBtn")
$importBtn = $window.FindName("ImportBtn")

# ===== 加载数据 =====
Load-Data

# ===== 设置窗口位置 =====
if ($settings.Left -ge 0) {
  $window.Top  = $settings.Top
  $window.Left = $settings.Left
} else {
  # 默认靠右
  $window.Left = [System.Windows.SystemParameters]::PrimaryScreenWidth - 320
  $window.Top  = 80
}
$window.Topmost = $settings.Topmost
if (-not $window.Topmost) {
  $pinBtn.Foreground = Brush("#585B70")
  $pinBtn.ToolTip    = "未置顶"
}

Update-TaskList

# ===== 事件绑定 =====
$addBtn.Add_Click({ Add-Task })

$taskInput.Add_KeyDown({
  param($s, $e)
  if ($e.Key -eq "Enter") { Add-Task; $e.Handled = $true }
})

$closeBtn.Add_Click({ Save-Data; $window.Close() })

$pinBtn.Add_Click({
  $window.Topmost = -not $window.Topmost
  if ($window.Topmost) {
    $pinBtn.Foreground = Brush("#F9E2AF")
    $pinBtn.ToolTip    = "置顶中 — 点击取消置顶"
  } else {
    $pinBtn.Foreground = Brush("#585B70")
    $pinBtn.ToolTip    = "未置顶 — 点击置顶"
  }
})

# ===== 导入按钮弹出菜单 =====
$importBtn.Add_Click({
  $menu = New-Object System.Windows.Controls.ContextMenu
  $menu.FontSize = 13

  $item1 = New-Object System.Windows.Controls.MenuItem -Property @{ Header = "从剪贴板粘贴导入" }
  $item1.Add_Click({ Import-FromClipboard })
  $menu.Items.Add($item1) | Out-Null

  $item2 = New-Object System.Windows.Controls.MenuItem -Property @{ Header = "从 JSON 文件导入" }
  $item2.Add_Click({ Import-FromJsonFile })
  $menu.Items.Add($item2) | Out-Null

  $importBtn.ContextMenu = $menu
  $menu.IsOpen = $true
})

# 拖拽移动窗口（仅标题栏区域）
$window.Add_MouseLeftButtonDown({
  param($s, $e)
  if ($e.GetPosition($window).Y -le 42) { $window.DragMove() }
})

# 窗口关闭时保存
$window.Add_Closed({ Save-Data })

# ===== 启动！ =====
$null = $window.ShowDialog()
