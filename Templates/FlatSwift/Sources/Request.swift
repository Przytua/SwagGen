{% include "Includes/Header.stencil" %}

import Foundation

{% if description and summary %}
{% if description == summary %}
/** {{ description }} */
{% else %}
/**
{{ summary }}

{{ description }}
*/
{% endif %}
{% else %}
{% if description %}
/** {{ description }} */
{% endif %}
{% if summary %}
/** {{ summary }} */
{% endif %}
{% endif %}
{% for enum in requestEnums %}
{% if not enum.isGlobal %}

{% filter indent:8 %}{% include "Includes/Enum.stencil" enum %}{% endfilter %}
{% endif %}
{% endfor %}

public final class {{ type }}Request: APIRequest<{{ successType|default:"APIEmptyResponseValue"}}> {
    {% for schema in requestSchemas %}

    {% filter indent:12 %}{% include "Includes/Model.stencil" schema %}{% endfilter %}
    {% endfor %}
    {% if nonBodyParams %}

    public struct Options {
        {% for param in nonBodyParams %}

        {% if param.description %}
        /** {{ param.description }} */
        {% endif %}
        public var {{ param.name }}: {{ param.optionalType }}
        {% endfor %}

        public init({% for param in nonBodyParams %}{{param.name}}: {{param.optionalType}}{% ifnot param.required %} = nil{% endif %}{% ifnot forloop.last %}, {% endif %}{% endfor %}) {
            {% for param in nonBodyParams %}
            self.{{param.name}} = {{param.name}}
            {% endfor %}
        }
    }

    public var options: Options
    {% endif %}
    {% if body %}

    public var {{ body.name}}: {{body.optionalType}}
    {% endif %}

    public init({% if body %}{{ body.name}}: {{ body.optionalType }}{% if nonBodyParams %}, {% endif %}{% endif %}{% if nonBodyParams %}options: Options{% endif %}) {
        {% if body %}
        self.{{ body.name}} = {{ body.name}}
        {% endif %}
        {% if nonBodyParams %}
        self.options = options
        {% endif %}
        let service = APIService<{{ successType|default:"APIEmptyResponseValue"}}>(id: "{{ operationId }}", tag: "{{ tag }}", method: "{{ method|uppercase }}", path: "{{ path }}", hasBody: {% if hasBody %}true{% else %}false{% endif %}{% if isUpload %}, isUpload: true{% endif %}{% if securityRequirement %}, securityRequirement: SecurityRequirement(type: "{{ securityRequirement.name }}", scopes: [{% for scope in securityRequirement.scopes %}"{{ scope }}"{% ifnot forloop.last %}, {% endif %}{% endfor %}]){% endif %})
        super.init(service: service){% if body %} {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .formatted(SwaggerClientAPI.dateEncodingFormatter)
            return try jsonEncoder.encode({% if body.isAnyType %}AnyCodable({{ body.name }}).value{% else %}{{ body.name }}{% endif %})
        }{% endif %}
    }
    {% if nonBodyParams %}

    /// convenience initialiser so an Option doesn't have to be created
    public convenience init({% for param in nonBodyParams %}{{ param.name }}: {{ param.optionalType }}{% ifnot param.required %} = nil{% endif %}{% ifnot forloop.last %}, {% endif %}{% endfor %}{% if nonBodyParams and body %}, {% endif %}{% if body %}{{ body.name}}: {{ body.optionalType}}{% ifnot body.required %} = nil{% endif %}{% endif %}) {
        {% if nonBodyParams %}
        let options = Options({% for param in nonBodyParams %}{{param.name}}: {{param.name}}{% ifnot forloop.last %}, {% endif %}{% endfor %})
        {% endif %}
        self.init({% if body %}{{ body.name}}: {{ body.name}}{% if nonBodyParams %}, {% endif %}{% endif %}{% if nonBodyParams %}options: options{% endif %})
    }
    {% endif %}
    {% if pathParams %}

    public override var path: String {
        return super.path{% for param in pathParams %}.replacingOccurrences(of: "{" + "{{ param.value }}" + "}", with: "\(self.options.{{ param.encodedValue }})"){% endfor %}
    }
    {% endif %}
    {% if queryParams %}

    public override var queryParameters: [String: Any] {
        var params: [String: Any] = [:]
        {% for param in queryParams %}
        {% if param.optional %}
        if let {{ param.name }} = options.{{ param.encodedValue }} {
          params["{{ param.value }}"] = {{ param.name }}
        }
        {% else %}
        params["{{ param.value }}"] = options.{{ param.encodedValue }}
        {% endif %}
        {% endfor %}
        return params
    }
    {% endif %}
    {% if formProperties %}

    public override var formParameters: [String: Any] {
        var params: [String: Any] = [:]
        {% for param in formProperties %}
        {% if param.optional %}
        if let {{ param.name }} = options.{{ param.encodedValue }} {
          params["{{ param.value }}"] = {{ param.name }}
        }
        {% else %}
        params["{{ param.value }}"] = options.{{ param.encodedValue }}
        {% endif %}
        {% endfor %}
        return params
    }
    {% endif %}
    {% if headerParams %}

    override var headerParameters: [String: String] {
        var headers: [String: String] = [:]
        {% for param in headerParams %}
        {% if param.optional %}
        if let {{ param.name }} = options.{{ param.encodedValue }} {
          headers["{{ param.value }}"] = {% if param.type == "String" %}{{ param.name }}{% else %}String(describing: {{ param.name }}){% endif %}
        }
        {% else %}
        headers["{{ param.value }}"] = {% if param.type == "String" %}options.{{ param.encodedValue }}{% else %}String(describing: options.{{ param.encodedValue }}){% endif %}
        {% endif %}
        {% endfor %}
        return headers
    }
    {% endif %}
}
