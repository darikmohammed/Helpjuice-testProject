require 'rails_helper'

RSpec.describe 'Integration', type: :system do
  before(:each) do
    @user = User.new(ref: 1)
    @user.save
  end

  describe 'Visit the home page' do
    it 'show the header' do
      visit '/'
      expect(page.body).to include('Articles')
    end

    it 'should redirect to add article page' do
      visit '/'
      find('a', text: 'New article').click
      sleep(0.1)
      expect(current_path).to eq(new_article_path)
    end

    # it 'should redirect to add new article' do
    #   visit '/'
    #   find('a', text: 'New article').click
    #   sleep(0.1)
    #   fill_in "title",	with: "What is ruby on rails?" 
    #   fill_in "publisher",	with: "Tester"
    #   fill_in "pbulished_year",	with: 2020  

    #   find('input', text: 'Create Article').click
    #   sleep(0.1)

    #   visit '/'
    #   expect(page.body).to include('What is ruby on rails?')

    # end
    # it 'show the search Items' do
    #   visit '/'
    #   fill_in "query",	with: "How is" 
    #   sleep(0.3)
    #   expect(page.body).to include('What is a good car?')
    # end
  end
end