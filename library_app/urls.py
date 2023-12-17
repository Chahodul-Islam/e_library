from django.contrib import admin
from django.urls import path, include
from . import views
from django.views.generic import TemplateView
urlpatterns = [
    path('users/', views.UsersHandler, name="users"),
    path('users/<int:id>/', views.UserHandler, name="user"),
    path('publishers/', views.PublishersHandler, name="publishers"),
    path('publishers/<int:id>/', views.PublisherHandler, name="publisher"),
    path('categories/', views.CategoriesHandler, name="categories"),
    path('categories/<int:id>/', views.CategoryHandler, name="category"),
    path('books/', views.BooksHandler, name="books"),
    path('books/<int:id>/', views.BookHandler, name="book"),
    path('reviews/', views.ReviewsHandler, name="reviews"),
    path('reviews/<int:id>/', views.ReviewHandler, name="review"),
]