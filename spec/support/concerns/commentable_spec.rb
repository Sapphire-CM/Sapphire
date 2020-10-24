RSpec.shared_examples 'a commentable' do |name|
  let(:model) { FactoryGirl.create (described_class.to_s.underscore.to_sym) }

  it "has #{name} comments" do
    expect { model.send("#{name}_comments") }.to_not raise_error
  end
end
