{% macro databricks__get_binding_char() %}
  {{ return('%s') }}
{% endmacro %}

{% macro databricks__create_csv_table(model, agate_table) %}
  {%- set column_override = model['config'].get('column_types', {}) -%}
  {%- set quote_seed_column = model['config'].get('quote_columns', None) -%}

  {% set sql %}
    create table {{ this.render() }} (
        {%- for col_name in agate_table.column_names -%}
            {%- set inferred_type = adapter.convert_type(agate_table, loop.index0) -%}
            {%- set type = column_override.get(col_name, inferred_type) -%}
            {%- set column_name = (col_name | string) -%}
            {{ adapter.quote_seed_column(column_name, quote_seed_column) }} {{ type }} {%- if not loop.last -%}, {%- endif -%}
        {%- endfor -%}
    )
    {{ dbt_databricks_file_format_clause() }}
    {{ dbt_databricks_partition_cols(label="partitioned by") }}
    {{ dbt_databricks_clustered_cols(label="clustered by") }}
    {{ dbt_databricks_location_clause() }}
    {{ dbt_databricks_comment_clause() }}
    {{ dbt_databricks_tblproperties_clause() }}
  {% endset %}

  {% call statement('_') -%}
    {{ sql }}
  {%- endcall %}

  {{ return(sql) }}
{% endmacro %}
