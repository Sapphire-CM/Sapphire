RSpec.shared_examples 'a commentable' do |name, klass|
  let(:model) { FactoryGirl.create (klass.to_s.underscore.to_sym) }

  it "has #{name} comments" do
    expect { model.send("#{name}_comments") }.to_not raise_error
  end
end
