require 'spec_helper'

feature "user generates rails app with karma/jasmine" do
  def app_name
    'dummy_rails'
  end

  def app_path
    join_paths(tmp_path, app_name)
  end

  before(:all) do
    make_it_so!("rails #{app_name} --js-test-lib karma")
  end

  let(:package_json_path) { File.join(app_path, 'package.json') }

  it 'creates a karma.config' do
    karma_config = File.join(app_path, 'karma.conf.js')
    expect(FileTest.exists?(karma_config)).to eq(true)
  end

  it 'creates a testHelper.js' do
    test_helper = File.join(app_path, 'spec/javascript/testHelper.js')
    expect(FileTest.exists?(test_helper)).to eq(true)
  end

  it 'includes karma in package.json' do
    in_package_json?(File.join(app_path, 'package.json')) do |json|
      expect(json["devDependencies"]["karma"]).to_not be_nil
    end
  end

  it 'includes jasmine in package.json' do
    in_package_json?(File.join(app_path, 'package.json')) do |json|
      expect(json["devDependencies"]["jasmine-core"]).to_not be_nil
    end
  end

  it 'adds coverage/* to gitignore' do
    expect(read_file('.gitignore')).to include("coverage/*\n")
  end

  it 'does not configure enzyme adapter in testHelper' do
    testHelper = read_file('spec/javascript/testHelper.js')
    expect(testHelper).to_not include("Enzyme.configure({ adapter: new EnzymeAdapter() })")
  end

  it 'includes enzyme.js with correct Enzyme config' do
    file_subpath = "spec/javascript/support/enzyme.js"
    support_file = File.join(app_path, file_subpath)
    expect(FileTest.exists?(support_file)).to eq(true)

    enzyme = read_file(file_subpath)
    expect(enzyme).to include("Enzyme.configure")
    expect(enzyme).to include("enzyme-adapter-react-16")
  end

  it 'karma.conf.js does not use @babel/polyfill' do
    expect(read_file('karma.conf.js')).to_not include("node_modules/@babel/polyfill/dist/polyfill.js")
  end

  it 'does not add jest as the test script in package.json' do
    in_package_json?(package_json_path) do |json|
      expect(json["scripts"]["test"]).to_not include("jest")
    end
  end
end
