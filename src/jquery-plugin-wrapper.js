/**
 * jQuery plugin declaration.
 * A wrapper is created in order to ensure one instance per DOM element
 */
var jQuery = require('jquery');

module.exports = {
    wrap: function(name, clazz, $) {

        if(!$) {
            if(!jQuery) { throw Error("jQuery not found"); }
            $ = jQuery;
        }
        var dataKey = "plugin_" + componentName;

        $.fn[ name ] = function ( method ) {
            var plugin = this.data( dataKey );
            if (plugin && plugin[method]) {
                return plugin[method].apply(plugin, [].slice.call(arguments, 1));

            } else if (typeof method === 'object' || !method) {

                return this.each(function() {
                    if ( !$.data( this, dataKey ) ) {
                        $.data( this, dataKey, new clazz( this, method ) );
                    }
                });

            } else {
                $.error('Method ' + method + ' does not exist on ' + name);
            }
        };
    }
}



