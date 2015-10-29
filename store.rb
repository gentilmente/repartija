class Store
  attr_accessor :result

  def initialize
    @result ||= {}
  end

  def process(store, individual_payment)
    @individual_payment = individual_payment
    @creditors, @debtors = devide_list(store)
    @creditors.each do |creditor, creditor_amount|
      collect(creditor, creditor_amount)
    end
    return @result
  end

  def devide_list(store)
    creditors, debtors = store.partition { |_,e| e < 0 }
    creditors = creditors.to_h
    debtors = debtors.to_h
    return creditors, debtors
  end

  def collect(creditor, creditor_amount)
    @actual_creditor_amount = creditor_amount
    @creditor_accum = 0
    @debtors.each  do |debtor, debt|
      pay(debtor, debt, creditor, creditor_amount)
    end
  end

  def pay(debtor, debt, creditor, creditor_amount)
    puts "4-#{result}"
    if(debt > 0 && @actual_creditor_amount < 0)
      @creditor_accum += debt
      @yet_to_pay = @creditor_accum + creditor_amount
      if( @yet_to_pay > 0 && @yet_to_pay < @individual_payment)
        payment = debt - @yet_to_pay
        balance(creditor, debtor, payment)
      elsif (debt < @individual_payment)
        balance(creditor, debtor, debt)
      elsif (@yet_to_pay <= 0)
        balance(creditor, debtor, @individual_payment)
      end
    end
  end

  def balance(creditor, debtor, payment)
    puts "5-#{result}"
    @debtors[debtor] = @yet_to_pay
    @creditors[creditor] += payment
    @actual_creditor_amount = @creditors[creditor]
    generate_output(creditor, debtor, payment)
  end

  def generate_output(creditor, debtor, payment)
    if(!@result.key?(creditor))
      @result[creditor.to_sym] = {debtor.to_sym => payment}
    else
      @result[creditor].store(debtor, payment)
    end
  	puts "6-#{result}"
  end
end
