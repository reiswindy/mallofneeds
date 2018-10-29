require "crsfml"

module Mallofneeds
  VERSION = "0.1.0"

  class Game

    SCREEN_WIDTH = 640
    SCREEN_WIDTH = 480

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
      @window = window
    end

    def process_events
      while event = @window.poll_event
        if event.is_a?(SF::Event::Closed)
          @window.close
        end
      end
    end

    def update
      
    end

    def render
      @window.clear(SF::Color::Black)
      #@window.draw
      @window.display
    end

    def run
      update
      process_events
      render
    end
  end

  class Player
    
  end

end
