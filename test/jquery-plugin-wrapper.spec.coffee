sinon = require "sinon"
chai = require "chai"
sinonChai = require "sinon-chai"
expect = chai.expect;

chai.use(sinonChai);
$ = require('jquery-latest').create();
wrapper = require '../src/jquery-plugin-wrapper'

class Component
	constructor: (@element, @settings) ->
	sayHello: ->
	giveMeOne: -> 1

instance = new Component()

$elem = $("<div id='testElement' class='test'></div>")
$elem2 = $("<div id='testElement2'><div class='first child'></div><div class='child'></div></div>")

describe 'jQuery plugin', ->

	afterEach ->
		$elem.data 'plugin_testPlugin', ''

	describe 'Initialization', ->

		beforeEach ->
			wrapper.wrap("testPlugin", Component, $)

		it 'should create component and store it in the jQuery data for the element', ->
			expect($elem.data 'plugin_testPlugin').to.be.empty
			result = $elem.testPlugin()

			expect($elem.data 'plugin_testPlugin').to.exist
			expect($elem.data('plugin_testPlugin').element.id).to.equal 'testElement'
			expect($elem.data('plugin_testPlugin').settings).not.to.exist

		it 'should return the jQuery element if no method is called', ->
			expect($elem.testPlugin()).to.equal $elem

		it 'should return the component element if api = true option is used', ->
			expect($elem.testPlugin({api: true}).giveMeOne).to.exist
			expect($elem.testPlugin({api: true}).giveMeOne()).to.equal 1

		it 'should create component with options', ->
			expect($elem.data 'plugin_testPlugin').to.be.empty
			$elem.testPlugin { someOption: true }
			expect($elem.data 'plugin_testPlugin').to.exist
			expect($elem.data('plugin_testPlugin').element.id).to.equal 'testElement'
			expect($elem.data('plugin_testPlugin').settings).to.exist
			expect($elem.data('plugin_testPlugin').settings.someOption).to.exist
			expect($elem.data('plugin_testPlugin').settings.someOption).to.be.true

		it 'should create component with options and also return the component if one of the options is api = true', ->
			expect($elem.data 'plugin_testPlugin').to.be.empty
			result = $elem.testPlugin { someOption: true, api: true }

			expect($elem.data 'plugin_testPlugin').to.exist
			expect(result).to.equal $elem.data('plugin_testPlugin')
			expect(result.element.id).to.equal 'testElement'
			expect(result.settings).to.exist
			expect(result.settings.someOption).to.exist
			expect(result.settings.someOption).to.be.true

		it 'should throw an error is jquery is undefined', ->
			expect(-> wrapper.wrap("testPlugin", Component)).to.throw("jQuery not found");

	describe 'API', ->
		beforeEach ->
			$elem.data 'plugin_testPlugin', instance

		it 'should delegate a valid method call to the component', ->
			api = sinon.spy instance, 'sayHello'

			$elem.testPlugin 'sayHello', "John Doe"

			expect(api).to.have.been.calledOnce
			expect(api).to.have.been.calledWithExactly "John Doe"

			instance.sayHello.restore()

		it 'method with no return value should return the jquery instance to enable chaining', ->
			api = sinon.spy instance, 'sayHello'

			result = $elem.testPlugin 'sayHello', "John Doe"

			expect(result).to.exist
			expect(result.testPlugin).to.equal $elem.testPlugin
			expect(result.is($elem)).to.be.true

			instance.sayHello.restore()

		it 'should return the internal instance if the plugin is called with api = true', ->
			result = $elem.testPlugin {api:true}

			expect(result).to.equal instance

		it 'should return the first element internal instance if the plugin is called with api = true for a multiple selector', ->
			$children = $elem2.find '.child'
			$children.testPlugin()
			$elem2.find('.first').data 'plugin_testPlugin', instance
			result = $children.testPlugin {api:true}
			expect(result).to.equal instance


		it 'method with return value should return the value', ->
			result = $elem.testPlugin 'giveMeOne'
			expect(result).to.exist
			expect(result).to.equal 1

		it 'should throw an error when an invalid method is called', ->
			try
				$elem.testPlugin 'invalidMethod'
				assert.fail()
			catch e
				expect(e.message).to.contain 'does not exist'
