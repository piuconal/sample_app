class DemoPartialsController < ApplicationController
  def new
    @zone = "Zone New Action"
    @date = Time.zone.today
  end

  def edit
    @zone = "Zone Edit Action"
    @date = Time.zone.today - 4
  end
end
