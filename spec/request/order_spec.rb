require_relative "spec_helper"

describe "Orders" do

  before :all do
    @user  = User.create USER1
    @user2 = User.create USER2
    login @user
  end

  it "logs user (Ali)" do
    get "/"
    body.should =~ /Ali/
  end

  it "makes a deposit" do
    # fake, mabe fake it another way?
    post "/deposits/fake_add"
    DepositFiat.count.should == 1
  end

  it "places an order [buy]" do
    @order_buy = { type: :buy, amount: 0.1, price: 500.0 }
    post "/orders", { order: @order_buy }
    Order.buy.size.should == 1 # todo: techeck the Order#buy implementation :)
  end

  it "makes a btc deposit" do
    # TODO: fixme, temporary
    # DepositBtc.create ? nah!
    R["users:#{@user2.id}:balance_btc"] = 0.05
  end

  it "places an order [sell]" do
    DepositBtc.create user: @user,  amount: 0.1
    @order_sell = { type: :sell, amount: 0.05, price: 495.0 }
    post "/orders", { order: @order_sell }
  end

  it "checks if the order is resolved" do
    # open is missing
    Order.sell.size.should  == 0
    Order.buy.size.should   == 1

    # closed is present (and first)
    OrderClosed.all.size.should   == 1
  end

  after(:all){ cleanup! }
end
