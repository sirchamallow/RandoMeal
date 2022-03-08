class PlansController < ApplicationController

  def index
    # Affiche le menu de la semaine
    @recipes = Recipe.order('RANDOM()').limit(5)

    cookies[:plan_recipes] = []
    cookies[:already_proposed] = @recipes.map(&:id).map(&:to_s).join(',')

    # bouton export (gem WickedPdf)
    @recipe = Recipe.first
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "file_name", template: "plans/index.html.erb"             # Excluding ".pdf" extension.
      end
    end
  end

  def add
    ap cookies[:plan_recipes]
    @recipe = Recipe.find(params[:recipe_id])
    plan_recipes = cookies[:plan_recipes].split(',')
    plan_recipes << @recipe.id.to_s
    ap Recipe.where(id: plan_recipes).pluck(:name)
    cookies[:plan_recipes] = plan_recipes.join(',')
  end

  def remove
    @recipe = Recipe.find(params[:recipe_id])
    plan_recipes = cookies[:plan_recipes].split(',')
    plan_recipes = plan_recipes - [@recipe.id.to_s]
    ap Recipe.where(id: plan_recipes).pluck(:name)
    cookies[:plan_recipes] = plan_recipes.join(',')
  end

  def refresh
    plan_recipes = cookies[:plan_recipes].split(',')
    already_proposed = cookies[:already_proposed].split(',')
    nb = 5 - plan_recipes.length

    if params[:filter].present?
      tag = Tag.find_by(name: params[:filter])
      ap tag
    end

    new_recipes = RandomRecipes.new(already_proposed, nb, tag ||= nil ).call
    ap new_recipes
    already_proposed += new_recipes.map(&:id)
    cookies[:already_proposed] = already_proposed.map(&:to_s).join(',')
    recipe_cards = new_recipes.map do |recipe|
      render_to_string(partial: "shared/card", locals: { recipe: recipe })
    end

    data = {recipe_cards: recipe_cards}
    render json: data
  end

  # Checkboxes du Menu
  def update
  end

  # Exporter le menu en PDF
  def export
    # Affiche le menu de la semaine (aléatoire avec une limite de 5)
    @recipes = Recipe.order('RANDOM()').limit(5)
    # Bouton export (gem WickedPdf)
    @recipe = Recipe.first
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "file_name", 
        template: "plans/pdf.html.erb",                     # Fichier de template
        title: 'RandoMeal, le menu de votre semaine',       # Titre de la page 
        page_size: "A4",                                    # Format de la page
        encoding: 'TEXT', 
        font_name: 'Arial',                                 # Police d'écritures
        margin: {top: 12, bottom: 12, left: 15, right: 12}  # Mise en page
      end
    end
  end

  private

  # Méthode privé des Checkboxes du Menu
  def plan_params
    params.require(:tag).permit(:name)
    # params.require(:plan).permit(:name)
    # params.require(:recipe).permit(:name, :image, :url_marmiton, :price, :prep_duration, :total_duration, :people)
    # params.require(:ingredient).permit(:name, :quantity, :mesurement, :recipe_id)
  end
end
