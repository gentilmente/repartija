class Balancer
  attr_accessor :result

  def initialize
    @result ||= {}
  end

  def process(input)
    balances = prepare_data_set(input)
    @creditors, @debtors = devide_list(balances)
    @creditors.each do |creditor, creditor_amount|
      collect(creditor, creditor_amount)
    end
    puts @result
  end

  private
  def prepare_data_set(input)
    @total = input.values.reduce(:+)
    @individual_payment = @total/input.length
    return input.inject({}) do |hash, (k, v)|
      hash.merge( k.to_sym => @individual_payment - v )
    end
  end

  def devide_list(balances)
    creditors, debtors = balances.partition { |_,e| e < 0 }
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
  end
end
