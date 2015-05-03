class RefactorGradingScale < ActiveRecord::Migration
  def up
    create_table :grading_scales do |t|
      t.references :term,       index: true
      t.string     :grade,      index: true,                 null: false
      t.boolean    :not_graded,              default: false, null: false
      t.boolean    :positive,                default: true,  null: false
      t.integer    :min_points,              default: 0,     null: false
      t.integer    :max_points,              default: 0,     null: false
      t.timestamps                                           null: false
    end
    add_index :grading_scales, [:term_id, :grade], name: "index_grading_scales_on_term_id_and_grade", unique: true

    Term.all.each do |term|
      gs = YAML.load(term.grading_scale).to_h

      new_entries = []
      gs.each do |points, grade|
        new_entries << { grade: grade, min_points: points }
      end

      # add ungraded entry
      new_entries.unshift({ grade: "ungraded", not_graded: true, positive: false })

      # set grade "5" to be non-positive
      new_entries.second[:positive] = false

      # best grade defaults to max_points=min_points, might be overridden by Term#points
      new_entries.last[:max_points] = if term.points > 0 && new_entries.last[:min_points] <= term.points
        term.points
      else
        new_entries.last[:min_points]
      end

      # set range values
      new_entries[1..-2].each_with_index do |entry, index|
        entry[:max_points] = new_entries[index + 2][:min_points] - 1
      end

      # create all grading scale entries in database table
      new_entries.each do |entry|
        term.grading_scales.create! entry
      end
    end

    # remove old column
    remove_column :terms, :grading_scale, :text
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
