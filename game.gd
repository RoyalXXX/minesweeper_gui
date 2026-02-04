#	Minesweeper GUI
#	
#	Copyright (c) 2025 Royal_X (MIT License)
#
# 	https://github.com/RoyalXXX
#  	https://royalxxx.itch.io
#   https://sourceforge.net/u/royal-x
#
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#	
#	The above copyright notice and this permission notice shall be included in all
#	copies or substantial portions of the Software.
#	
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#	SOFTWARE.

extends TileMapLayer

var pid
var stdio : FileAccess
const N = 16

func _ready() -> void:
	resize_window()
	create_process()
	startGame()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_pos = get_local_mouse_position()
		var tile_coords = local_to_map(mouse_pos) 
		if Input.is_action_just_pressed("mouse_left"):
			on_mouse_left(tile_coords)
		if Input.is_action_just_pressed("mouse_right"):
			on_mouse_right(tile_coords)
	elif event is InputEventKey:
		if Input.is_action_just_pressed("restart"):
			startGame()
		if Input.is_action_just_pressed("quit"):
			if stdio:
				stdio.store_line('quit')
				stdio.close()
				OS.kill(pid)
			get_tree().quit()

func create_process():
	var path = 'engine.exe'
	if not FileAccess.file_exists(path):
		$"../CanvasLayer".visible = true
		return
	var process_result = OS.execute_with_pipe(path, [])
	if process_result.is_empty():
		return
	pid = process_result.pid
	stdio = process_result.stdio
	
func get_text() -> String:
	var buffer = stdio.get_buffer(1024)
	return buffer.get_string_from_utf8()

func startGame():
	if not stdio:
		return
	stdio.store_line('startGame')
	DisplayServer.window_set_title('Minesweeper GUI : Game: %s' % get_text())
	updateView()

func getBoardState():
	stdio.store_line('getBoardState')
	
func updateView():
	getBoardState()
	var arr_as_str = get_text().replace('\r\n', '')
	var numbers = arr_as_str.split(' ', false)
	for i in range(N):
		for j in range(N):
			set_cell(Vector2i(i, j), 0, Vector2i(int(numbers[i * N + j]), 0))
	
func _exit_tree() -> void:
	if not stdio:
		return
	stdio.store_line('quit')
	stdio.close()
	OS.kill(pid)

func resize_window():
	var screen_size = DisplayServer.screen_get_usable_rect().size
	var size = min(screen_size.x * 0.8, screen_size.y * 0.8) # 80% of window
	get_viewport().size = Vector2i(size, size)
	@warning_ignore("integer_division")
	get_window().position = (screen_size - get_window().size) / 2

func on_mouse_left(coords : Vector2i):
	if not stdio:
		return
	stdio.store_line('clickCell %d %d' % [coords.x, coords.y])
	DisplayServer.window_set_title('Minesweeper GUI : Event: %s' % get_text())
	updateView()

func on_mouse_right(coords : Vector2i):
	if not stdio:
		return
	stdio.store_line('setFlag %d %d' % [coords.x, coords.y])
	updateView()
