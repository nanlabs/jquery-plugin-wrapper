/**
 * jQuery plugin declaration.
 * A wrapper is created in order to ensure one instance per DOM element
 */

module.exports = {
    wrap: function(name, clazz, $) {
		if(!$) {
            throw Error("jQuery not found");
        }
        var dataKey = "plugin_" + name;

        $.fn[ name ] = function ( method ) {
            var plugin = this.data( dataKey );
            if (plugin && plugin[method]) {
                var value = plugin[method].apply(plugin, [].slice.call(arguments, 1));
				if(typeof value === 'undefined') { value = $(this); }
				return value;

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



