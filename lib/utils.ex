defmodule GenReport.Utils do
  @years [2016, 2017, 2018, 2019, 2020]
  def get_all_people_names(report) do
    report
    |> Enum.map(fn element -> Enum.fetch!(element, 0) end)
    |> Enum.uniq()
  end

  def sum_all_hours_per_person(report, person_name) do
    %{
      person_name =>
        report
        |> Enum.filter(fn element -> Enum.fetch!(element, 0) == person_name end)
        |> Enum.map(fn element -> Enum.fetch!(element, 1) end)
        |> Enum.sum()
    }
  end

  def gen_all_hours_map(file_content) do
    names = GenReport.Utils.get_all_people_names(file_content)

    Enum.map(names, fn name -> GenReport.Utils.sum_all_hours_per_person(file_content, name) end)
    |> map_to_tuple()
  end

  def map_to_tuple(map) do
    map
    |> Enum.chunk_by(fn element -> %{Map.keys(element) => Map.values(element)} end)
  end

  def gen_hours_per_month_map(file_content) do
    get_all_people_names(file_content)
    |> Enum.map(fn element ->
      %{
        element => get_hours_per_month_by_person(element, file_content)
      }
    end)
  end

  def get_hours_per_month_by_person(person_name, file_content) do
    # GenReport.Parser.get_months()
    file_content
    |> build_person_month_array(person_name)
  end

  def build_person_month_array(file_content, person_name) do
    month_array = Map.values(GenReport.Parser.get_months())

    month_array
    |> Enum.map(fn element -> %{element => get_hours_sum(element, person_name, file_content)} end)

    # person_by_name = get_all_people_names(file_content)
  end

  def get_all_lines_with_person_name(file_content, person_name) do
    file_content
    |> Enum.filter(fn line -> Enum.fetch!(line, 0) == person_name end)
  end

  def get_hours_sum(month, person_name, file_content) do
    file_content
    |> Enum.filter(fn line ->
      Enum.fetch!(line, 3) == month &&
        Enum.fetch!(line, 0) == person_name
    end)
    |> Enum.map(fn element -> Enum.fetch!(element, 1) end)
    |> Enum.sum()
  end

  def get_all_hours_per_year(file_content) do
    get_all_people_names(file_content)
    |> Enum.map(fn line ->
      %{
        line => get_person_hours_per_year(file_content, line)
      }
    end)
  end

  def get_person_hours_per_year(file_content, person_name) do
    @years
    |> Enum.map(fn year ->
      %{year => get_person_hours_per_year(file_content, person_name, year)}
    end)
  end

  def get_person_hours_per_year(file_content, person_name, year) do
    file_content
    |> Enum.filter(fn line ->
      Enum.fetch!(line, 0) == person_name &&
        Enum.fetch!(line, 4) == year
    end)
    |> Enum.map(fn element -> Enum.fetch!(element, 1) end)
    |> Enum.sum()
  end
end
