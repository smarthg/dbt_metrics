{% macro gen_calendar_join(group_values, grain) %}
    {{ return(adapter.dispatch('gen_calendar_join', 'metrics')(group_values, grain)) }}
{%- endmacro -%}

{% macro default__gen_calendar_join(group_values, grain) %}
        left join calendar
        {%- if group_values.window is not none and grain not in ['hour', 'fifteen_minute'] %}
            on cast(base_model.{{group_values.timestamp}} as date) > dateadd({{group_values.window.period}}, -{{group_values.window.count}}, calendar.date_day)
            and cast(base_model.{{group_values.timestamp}} as date) <= calendar.date_day
        {%- elif grain == 'fifteen_minute' %}
            on dateadd(minute, floor(datediff(minute, 0, {{group_values.timestamp}}) / 15.0, 0) * 15, 0) = calendar.date_fifteen_minute
        {%- elif grain == 'hour' %}
            on date_trunc('hour', {{group_values.timestamp}}) = calendar.date_hour
        {%- else %}
            on cast(base_model.{{group_values.timestamp}} as date) = calendar.date_day
        {% endif -%}
        
{% endmacro %}

{% macro bigquery__gen_calendar_join(group_values, grain) %}
        left join calendar
        {%- if group_values.window is not none and grain not in ['hour', 'fifteen_minute'] %}
            on cast(base_model.{{group_values.timestamp}} as date) > date_sub(calendar.date_day, interval {{group_values.window.count}} {{group_values.window.period}})
            and cast(base_model.{{group_values.timestamp}} as date) <= calendar.date_day
        {%- elif grain == 'fifteen_minute' -%}
            on dateadd(minute, floor(datediff(minute, 0, {{group_values.timestamp}}) / 15.0, 0) * 15, 0) = calendar.date_fifteen_minute
        {%- elif grain == 'hour' -%}
            on date_trunc('hour', {{group_values.timestamp}}) = calendar.date_hour
        {%- else %}
            on cast(base_model.{{group_values.timestamp}} as date) = calendar.date_day
        {% endif -%}
{% endmacro %}

{% macro postgres__gen_calendar_join(group_values, grain) %}
        left join calendar
        {%- if group_values.window is not none and grain not in ['hour', 'fifteen_minute'] %}
            on cast(base_model.{{group_values.timestamp}} as date) > calendar.date_day - interval '{{group_values.window.count}} {{group_values.window.period}}'
            and cast(base_model.{{group_values.timestamp}} as date) <= calendar.date_day
        {%- elif grain == 'fifteen_minute' -%}
            on dateadd(minute, floor(datediff(minute, 0, {{group_values.timestamp}}) / 15.0, 0) * 15, 0) = calendar.date_fifteen_minute
        {%- elif grain == 'hour' -%}
            on date_trunc('hour', {{group_values.timestamp}}) = calendar.date_hour
        {%- else %}
            on cast(base_model.{{group_values.timestamp}} as date) = calendar.date_day
        {% endif -%}
{% endmacro %}

{% macro redshift__gen_calendar_join(group_values, grain) %}
        left join calendar
        {%- if group_values.window is not none and grain not in ['hour', 'fifteen_minute'] %}
            on cast(base_model.{{group_values.timestamp}} as date) > dateadd({{group_values.window.period}}, -{{group_values.window.count}}, calendar.date_day)
            and cast(base_model.{{group_values.timestamp}} as date) <= calendar.date_day
        {%- elif grain == 'fifteen_minute' -%}
            on dateadd(minute, floor(datediff(minute, 0, {{group_values.timestamp}}) / 15.0, 0) * 15, 0) = calendar.date_fifteen_minute
        {%- elif grain == 'hour' -%}
            on date_trunc('hour', {{group_values.timestamp}}) = calendar.date_hour
        {%- else %}
            on cast(base_model.{{group_values.timestamp}} as date) = calendar.date_day
        {% endif -%}
{% endmacro %}
