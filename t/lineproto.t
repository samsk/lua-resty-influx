use Test::Nginx::Socket::Lua;

plan tests => 3 * blocks();

no_shuffle();
run_tests();

__DATA__

=== TEST 1: build_tag_set
--- config
	location /t {
		content_by_lua '
			local lp = require "resty.influx.lineproto"

			local tags = {
				{ key = "foo", value = "bar" }
			}

			ngx.say(lp.build_tag_set(tags))

		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
foo=bar
--- no_error_log
[error]

=== TEST 2: build_fieldset
--- config
	location /t {
		content_by_lua '
			local lp = require "resty.influx.lineproto"

			local fields = {
				{ key = "foo", value = "bar" }
			}

			ngx.say(lp.build_tag_set(fields))

		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
foo=bar
--- no_error_log
[error]

=== TEST 3: quote_field_value
--- config
	location /t {
		content_by_lua '
			local lp = require "resty.influx.lineproto"

			ngx.say(lp.quote_field_value("foo"))

		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
"foo"
--- no_error_log
[error]

=== TEST 4: quote_field_key
--- config
	location /t {
		content_by_lua '
			local lp = require "resty.influx.lineproto"

			local s = "foo,bar=ba z"

			ngx.say(lp.quote_field_key(s))

		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
foo\,bar\=ba\ z
--- no_error_log
[error]

=== TEST 5: quote_tag_part
--- config
	location /t {
		content_by_lua '
			local lp = require "resty.influx.lineproto"

			local s = "foo,bar=ba z"

			ngx.say(lp.quote_tag_part(s))

		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
foo\,bar\=ba\ z
--- no_error_log
[error]

=== TEST 6: quote_measureent
--- config
	location /t {
		content_by_lua '
			local lp = require "resty.influx.lineproto"

			local s = "foo,ba r"

			ngx.say(lp.quote_tag_part(s))

		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
foo\,ba\ r
--- no_error_log
[error]

=== TEST 7: build_line_proto_stmt (1/2)
--- config
	location /t {
		content_by_lua '
			local lp = require "resty.influx.lineproto"

			local influx = {
				_measurement = "foo",
				_stamp = 12345,
				_tag_set = { [[foo="bar"]] },
				_field_set = { "value=1" },
			}

			ngx.say(lp.build_line_proto_stmt(influx))
		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
foo,foo="bar" value=1 12345
--- no_error_log
[error]

=== TEST 8: build_line_proto_stmt (2/2)
--- config
	location /t {
		content_by_lua '
			local lp = require "resty.influx.lineproto"

			local influx = {
				_measurement = "foo",
				_stamp = 12345,
				_tag_set = {},
				_field_set = { "value=1" },
			}

			ngx.say(lp.build_line_proto_stmt(influx))
		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
foo value=1 12345
--- no_error_log
[error]
