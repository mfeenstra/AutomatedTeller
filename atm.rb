#!/usr/bin/env ruby
### matt.a.feenstra@gmail.com

class AutomatedTeller
  attr_accessor :winner
  attr_reader :horses, :inventory

  def initialize
    restock
    @winner = 1
    @horses = [ { 'That Darn Gray Cat' => 5 },
                { 'Fort Utopia' => 10 },
                { 'Count Sheep' => 9 },
                { 'Ms Traitour' => 4 },
                { 'Real Princess' => 3 },
                { 'Pa Kettle' => 5 },
                { 'Gin Stinger' => 6 } ]
    display
    menu
  end

  def restock
    @inventory = { '$1' => 10,
                   '$5' => 10,
                   '$10' => 10,
                   '$20' => 10,
                   '$100' => 10 }
    @total = total_funds
  end

  def display
    puts "\nInventory:"
    @inventory.each do |denomination, count|
      puts "#{denomination},#{count}"
    end
    puts "\nHorses:"
    @horses.each.with_index(1) do |horse, index|
      print "#{index},#{horse.keys.first},#{horse.values.first},"
      if index == @winner then
        puts 'won'
      else
        puts 'lost'
      end
    end
  end

  def set_winner(index_number)
    @winner = index_number if valid_horse_number(index_number)
  end

  def menu_options
    print "\n'R' or 'r' - restocks the cash inventory\n" \
          "'Q' or 'q' - quits the application\n" \
          "'W' or 'w' [1-7] - sets the winning horse number\n" \
          "[1-7] <amount> - specifies the horse wagered on and the amount of the bet\n\n"
  end

  def valid_horse_number(index)
    if !(index.is_a? Integer) || (index < 1) || (index > @horses.size) then
      puts "Invalid Horse Number: #{index}"
      return false
    end
    return true
  end

  def valid_bet(amount)
    if !(amount.is_a? Integer) || (amount <= 0) then
      puts "Invalid Bet: #{amount}"
      return false
    end
    if amount > total_funds then
      puts "Insufficient Funds: #{amount}"
      return false
    end
    return true
  end

  def total_funds
    total = 0
    @inventory.each do |denomination, count|
      total += denomination.tr('$', '').to_i * count
    end
    return total
  end

  def payout(index, wager)
    unless valid_horse_number(index) && index == @winner then
      print 'No Payout: '
      if @horses[index - 1].nil? then
        puts '<n/a>'
      else
        puts @horses[index - 1].keys.first
      end
      return false
    end

    if index == @winner then
      bid_factor = @horses[index - 1].values.first
      unless valid_bet(wager * bid_factor) then return false end
      puts "Payout: #{@horses[index - 1].keys.first}, $#{wager * bid_factor}"
      dispense_cash(wager)
      return true
    end

    return false
  end

  def dispense_cash(amount)
    unless valid_bet(amount) then return end
    hundreds = twenties = tens = fives = ones = 0

    if (amount / 100) <= @inventory['$100'] then
      hundreds = amount / 100
      @inventory['$100'] = @inventory['$100'] - hundreds
    else
      hundreds = @inventory['$100']
      @inventory['$100'] = 0
    end
    amount -= (hundreds * 100)

    if (amount / 20) <= @inventory['$20'] then
      twenties = amount / 20
      @inventory['$20'] = @inventory['$20'] - twenties
    else
      twenties = @inventory['$20']
      @inventory['$20'] = 0
    end
    amount -= (twenties * 20)

    if (amount / 10) <= @inventory['$10'] then
      tens = amount / 10
      @inventory['$10'] = @inventory['$10'] - tens
    else
      tens = @inventory['$10']
      @inventory['$10'] = 0
    end
    amount -= (tens * 10)

    if (amount / 5) <= @inventory['$5'] then
      fives = amount / 5
      @inventory['$5'] = @inventory['$5'] - fives
    else
      fives = @inventory['$5']
      @inventory['$5'] = 0
    end
    amount -= (fives * 5)

    if amount > @inventory['$1'] then
      puts "Not enough $1 available for exact change ($#{amount})."
    end
    if amount <= @inventory['$1'] then
      ones = amount
      @inventory['$1'] = @inventory['$1'] - ones
    else
      ones = @inventory['$1']
      @inventory['$1'] = 0
    end
    print "Dispensing:\n" \
          "$1,#{ones}\n"  \
          "$5,#{fives}\n" \
          "$10,#{tens}\n" \
          "$20,#{twenties}\n" \
          "$100,#{hundreds}\n"
    return true
  end

  def menu
    loop do
      menu_options
      option = gets.chomp.downcase

      case option
      when 'r'
          restock
      when /(\d+)\s(\d+)/
          payout($1.to_i, $2.to_i)
      when /w\s(\d+)/
          if valid_horse_number($1.to_i) then set_winner($1.to_i) end
      when 'q'
          exit
        else
          menu_options
      end
      display
    end
  end
end

AutomatedTeller.new
