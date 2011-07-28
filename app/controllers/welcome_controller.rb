class WelcomeController < ApplicationController
  def index
    if current_user
      @tomato = current_user.tomatoes.build
      @tomatoes = current_user.tomatoes.order_by([[:created_at, :desc]]).group_by do |tomato|
        date = tomato.created_at
        Time.mktime(date.year, date.month, date.day)
      end
      
      count_query_opts = {
        :key => :user_id,
        :initial => {:count => 0},
        :reduce => "function(doc, prev) {prev.count += 1}"
      }

      @day_leaderboard = Tomato.sort_limit_and_map(Tomato.collection.group(count_query_opts.merge(:cond => {:created_at => {'$gt' => Time.now.beginning_of_day}})))
      @week_leaderboard = Tomato.sort_limit_and_map(Tomato.collection.group(count_query_opts.merge(:cond => {:created_at => {'$gt' => Time.now.beginning_of_week}})))
      @month_leaderboard = Tomato.sort_limit_and_map(Tomato.collection.group(count_query_opts.merge(:cond => {:created_at => {'$gt' => Time.now.beginning_of_month}})))
      @everytime_leaderboard = Tomato.sort_limit_and_map(Tomato.collection.group(count_query_opts))
    end
  end
end
