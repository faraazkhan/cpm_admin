module FormattedChangeset
  def formatted_changeset(changeset)
    arbre_table = <<-TABLE
    table_for
    TABLE
    eval arbre_table
  end
end
