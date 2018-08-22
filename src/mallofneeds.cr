require "crsfml"

module Mallofneeds
  VERSION = "0.1.0"

  class Game

    SCREEN_WIDTH = 640
    SCREEN_HEIGHT = 480

    SPRITESHEET = SF::Texture.from_file("media/sprites/item_texture.png")
    FONT = SF::Font.from_file("media/Hack-Regular.ttf")

    @@variables = {
      :health => 0,
      :fun => 0,
      :happiness => 3, 
      :money => 300, 
      :debt => 0, 
      :stage => 1, 
      :expenses => 0,
      :times_slacked => 0,
    }
    
    @window : SF::RenderWindow

    def initialize
      video_mode = SF::VideoMode.new(SCREEN_WIDTH, SCREEN_HEIGHT)
      window = SF::RenderWindow.new(video_mode, "Ｍａｌｌ ｏｆ Ｎｅｅｄｓ")
      window.vertical_sync_enabled = true
      @window = window
      @player = Player.new({SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2})
      @items = [] of Item
    end

    def process_events
      while event = @window.poll_event
        case event
        when SF::Event::Closed
          @window.close
        when SF::Event::KeyPressed
          @player.key_pressed(event.code)
        when SF::Event::KeyReleased
          @player.key_released(event.code)
        else 
        end
      end
    end

    def update
      @player.update
    end

    def render
      @window.clear(SF::Color::Black)
      @window.draw(@player)
      @window.display
    end

    def run
      while @window.open?
        process_events
        update
        render
      end
    end
  end

  class Player
    include SF::Drawable

    SPEED = 4

    @sprite : SF::Sprite
    @speed_multiplier = 1
    @moving_up = false
    @moving_down = false
    @moving_left = false
    @moving_right = false

    def initialize(position)
      sprite = SF::Sprite.new
      sprite.texture = Game::SPRITESHEET
      sprite.texture_rect = SF.int_rect(0, 0, 15, 13)
      sprite.position = position
      @sprite = sprite
    end

    def update
      speed_x = speed_y = 0
      speed_y += SPEED * @speed_multiplier * (-1) if @moving_up
      speed_x += SPEED * @speed_multiplier * (-1) if @moving_left
      speed_y += SPEED * @speed_multiplier if @moving_down
      speed_x += SPEED * @speed_multiplier if @moving_right
      old_x, old_y = @sprite.position
      new_x = old_x + speed_x
      new_y = old_y + speed_y
      new_x = 0 if new_x < 0
      new_x = Game::SCREEN_WIDTH - @sprite.global_bounds.width if new_x + @sprite.global_bounds.width > Game::SCREEN_WIDTH
      new_y = 0 if new_y < 0
      new_y = Game::SCREEN_HEIGHT - @sprite.global_bounds.height if new_y + @sprite.global_bounds.height > Game::SCREEN_HEIGHT
      @sprite.position = {new_x, new_y}
    end

    def key_pressed(key)
      @moving_up = true if key.w?
      @moving_down = true if key.s?
      @moving_left = true if key.a?
      @moving_right = true if key.d?
    end

    def key_released(key)
      @moving_up = false if key.w?
      @moving_down = false if key.s?
      @moving_left = false if key.a?
      @moving_right = false if key.d?
    end

    def draw(target, states)
      target.draw(@sprite)
    end
  end

  abstract class Item
    include SF::Drawable

    @fun : Int32
    @price : Int32
    @health : Int32
    @lifetime : Int32
    @label : SF::Text
    @clock : SF::Clock
    @sprite : SF::Sprite

    def initialize(@lifetime, @price, @fun, @health, position)
      sprite = SF::Sprite.new
      sprite.texture = Game::SPRITESHEET
      sprite.position = position
      @sprite = sprite
      @label = SF::Text.new("#{price}", Game::FONT, 15)
      @clock = SF::Clock.new
    end

    def update
    end

    def draw(target, states)
      target.draw(@sprite)
      target.draw(@label)
    end

    def expired?
      @clock.elapsed_time > @lifetime
    end

    class Medicine < Item
      FUN = 0
      HEALTH = 30
      def initialize(lifetime, price, position)
        super(lifetime, price, FUN, HEALTH, position)
        @sprite.texture_rect = SF.int_rect(16, 0, 14, 22)
        x, y = position
        @label.position = {x + (@sprite.global_bounds.width / 2).to_i - (@label.global_bounds.width / 2).to_i, y + 22 + 2}
      end
    end

    class Food < Item
      FUN = 10
      HEALTH = 20
      def initialize(lifetime, price, position)
        super(lifetime, price, FUN, HEALTH, position)
        @sprite.texture_rect = SF.int_rect(32, 0, 20, 20)
        x, y = position
        @label.position = {x + (@sprite.global_bounds.width / 2).to_i - (@label.global_bounds.width / 2).to_i, y + 20 + 2}
      end
    end

    class Disc < Item
      FUN = 30
      HEALTH = 0
      def initialize(lifetime, price, position)
        super(lifetime, price, FUN, HEALTH, position)
        @sprite.texture_rect = SF.int_rect(53, 0, 20, 20)
        x, y = position
        @label.position = {x + (@sprite.global_bounds.width / 2).to_i - (@label.global_bounds.width / 2).to_i, y + 20 + 2}
      end
    end
  end

end
