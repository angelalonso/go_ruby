require 'curses'

include Curses

#TODO: 
#print the table AND A FOOTER
# set a "cursor"
#wait for key stroke
# if movement: move to the correct one (not 1:1 with what is shown)
# if enter: place the stone, change to other player


# Class GUI
## Controls everything
## It should be able to load Map, robots, and wait for movements
class Gui
  COLS  = 19
  LINES = 19
  def initialize
    Curses::Window.new(LINES, COLS, 1, 0)
    Curses.start_color
    Curses.attrset(A_DIM)
    Curses.init_pair(COLOR_CYAN,COLOR_BLACK,COLOR_CYAN)
    Curses.init_pair(COLOR_WHITE,COLOR_BLACK,COLOR_WHITE)
    Curses.init_pair(COLOR_YELLOW,COLOR_BLACK,COLOR_YELLOW)
    Curses.init_pair(COLOR_BLACK,COLOR_WHITE,COLOR_BLACK)
    Curses.init_pair(COLOR_BLUE,COLOR_BLACK,COLOR_BLUE)
    target = Target.new(COLS,LINES)
    play = Play_Control.new
    begin
      @gameboard = Board.new(COLS,LINES)
      stdscr.keypad = true
      until (input = Curses.getch) == 'q'
        case input
        when KEY_UP
          target.update_pos(-1,'y')
        when KEY_DOWN
          target.update_pos(1,'y')
        when KEY_LEFT
          target.update_pos(-1,'x')
        when KEY_RIGHT
          target.update_pos(1,'x')
        when KEY_BACKSPACE
          @gameboard.newstone(target.x,target.y,play.currentplayer)
          play.next
        end
        draw_board(@gameboard)
        target.showinboard(Curses,play.currentplayer)
      end
    ensure
      Curses.close_screen
      puts @gameboard
    end
  end
  
  def init_board(lines_in,cols_in)
    newhash = {}
    lines = lines_in
    cols = cols_in
    for linecounter in 0..(lines - 1) do
      for colcounter in 0..(cols - 1) do
        boardline = '-'
        newhash[linecounter.to_s + ',' + colcounter.to_s] = '-'
      end
    end
    return newhash
  end  

  def draw_board(hash)
    @cols = hash.keys.last.to_s.split(',')[0]
    @lines = hash.keys.last.to_s.split(',')[1]
    for position_y in 0..@lines.to_i
      for position_x in 0..(@cols.to_i)
        Curses.setpos(position_y,position_x * 2)
        case hash[(position_x).to_s + ',' + position_y.to_s]
        when '-'
          Curses.attron(color_pair(COLOR_CYAN)|A_NORMAL){Curses.addstr(' ')}
          Curses.setpos(position_y,(position_x * 2) + 1)
          Curses.attron(color_pair(COLOR_CYAN)|A_NORMAL){Curses.addstr(' ')}
        when '#'
          Curses.attron(color_pair(COLOR_WHITE)|A_NORMAL){Curses.addstr(' ')}
          Curses.setpos(position_y,(position_x * 2) + 1)
          Curses.attron(color_pair(COLOR_WHITE)|A_NORMAL){Curses.addstr(' ')}
        when 'O'
          Curses.attron(color_pair(COLOR_BLACK)|A_NORMAL){Curses.addstr(' ')}
          Curses.setpos(position_y,(position_x * 2) + 1)
          Curses.attron(color_pair(COLOR_BLACK)|A_NORMAL){Curses.addstr(' ')}
        end
      end
    end
    Curses.refresh
  end
end


# Class BOARD
## Draws the base board, just that
## SYMBOLS for the whole program board_hashes:
##   - empty
##   O white stone
##   @ black stone
##   X cursor 
class Board < Hash
  def initialize(cols_in,lines_in)
    lines = lines_in
    cols = cols_in
    for linecounter in 0..(lines - 1) do
      for colcounter in 0..(cols - 1) do
        boardline = '-'
        self[linecounter.to_s + ',' + colcounter.to_s] = '-'
      end
    end
  end

  def newstone(pos_x,pos_y,currentplayer)
    thiskey = pos_x.to_s + ',' + pos_y.to_s
    case currentplayer
    when 'Player1'
      self[thiskey] = '#'
    when 'Player2'
      self[thiskey] = 'O'
    end
  end
end

# Class TARGET
## Controls the cursor 
class Target
  def initialize(max_x,max_y)
    @max_x = max_x - 1
    @max_y = max_y - 1
    @target_x = max_x / 2
    @target_y = max_y / 2
  end

  def update_pos(change,coord)
    case coord
      when 'x'
        @target_x = @target_x + change
        if @target_x >= @max_x
          @target_x = @max_x
        elsif @target_x <= 0
          @target_x = 0
        end
      when 'y'
        @target_y = @target_y + change 
        if @target_y >= @max_y
          @target_y = @max_y
        elsif @target_y <= 0
          @target_y = 0
        end
      end
  end

  def x
    return @target_x
  end
  def y
    return @target_y
  end
  def showinboard(curses, currentplayer)
    curses.setpos(self.y, self.x * 2)
    case currentplayer
    when 'Player1'
      Curses.attron(color_pair(COLOR_YELLOW)|A_NORMAL){Curses.addstr('+')}
    when 'Player2'
      Curses.attron(color_pair(COLOR_BLUE)|A_NORMAL){Curses.addstr('+')}
    end
  end
end

## Controls the Play
class Play_Control
  def initialize
    @turn = 'Player1'
  end
 
  def next
    case @turn
    when 'Player1'
      @turn = 'Player2'
    when 'Player2'
      @turn = 'Player1'
    end
  end

  def currentplayer
    return @turn
  end
end

my = Gui.new
