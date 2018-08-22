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
      @items.reject! do |item|
        collides = @player.collides_with?(item.collision_rect)
        consume(item) if collides
        collides || item.expired?
      end
      spawn_random_item if needs_item?
    end

    def needs_item?
      if @items.empty? || (@items.size < 5 && rand(1000) <= 20)
        true
      else
        false
      end
    end

    def spawn_random_item
      @items.push(Item.create_random({rand(SCREEN_WIDTH), rand(SCREEN_HEIGHT)}))
    end

    def consume(item)
      @@variables[:fun] += item.fun
      @@variables[:health] += item.health
      @@variables[:money] -= item.price
      puts @@variables
    end

    def render
      @window.clear(SF::Color::Black)
      @window.draw(@player)
      @items.each do |item|
        @window.draw(item)
      end
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

    def collides_with?(rect : SF::Rect)
      !collision_rect.intersects?(rect).nil?
    end

    def collision_rect
      @sprite.global_bounds
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

    def initialize(@lifetime, @price, @fun, @health, position, texture_rect)
      x, y = position
      sprite = SF::Sprite.new
      sprite.texture = Game::SPRITESHEET
      sprite.position = position
      sprite.texture_rect = texture_rect
      label = SF::Text.new("#{price}", Game::FONT, 15)
      label.position = {x + ((sprite.global_bounds.width - label.global_bounds.width) / 2).to_i, y + texture_rect.height + 2}
      @sprite = sprite
      @label = label
      @clock = SF::Clock.new
    end

    getter :fun
    getter :price
    getter :health
    
    def collision_rect
      @sprite.global_bounds
    end

    def update
    end

    def draw(target, states)
      target.draw(@sprite)
      target.draw(@label)
    end

    def expired?
      @clock.elapsed_time.as_seconds > @lifetime
    end

    class Medicine < Item
      FUN = 0
      HEALTH = 30
      CATEGORY_ID = 0
      def initialize(lifetime, price, position)
        rect = SF.int_rect(16, 0, 14, 22)
        super(lifetime, price, FUN, HEALTH, position, rect)
      end
    end

    class Food < Item
      FUN = 10
      HEALTH = 20
      CATEGORY_ID = 1
      def initialize(lifetime, price, position)
        rect = SF.int_rect(32, 0, 20, 20)
        super(lifetime, price, FUN, HEALTH, position, rect)
      end
    end

    class Disc < Item
      FUN = 30
      HEALTH = 0
      CATEGORY_ID = 2
      def initialize(lifetime, price, position)
        rect = SF.int_rect(53, 0, 20, 20)
        super(lifetime, price, FUN, HEALTH, position, rect)
      end
    end

    def self.create_random(position) : Item
      case category_id = rand(3)
      when Medicine::CATEGORY_ID
        Medicine.new(rand(3) + 2, [40, 80, 150].sample, position).as(Item)
      when Food::CATEGORY_ID
        Food.new(rand(3) + 2, [5, 15, 30, 40].sample, position).as(Item)
      when Disc::CATEGORY_ID
        Disc.new(rand(3) + 2, [15, 35, 55, 80].sample, position).as(Item)
      else
        raise "Unkown category id"
      end
    end
  end

end
