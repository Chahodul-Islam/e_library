from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .utils import database
import json
import psycopg2
from psycopg2 import Error

@api_view(['GET', 'POST'])
def UsersHandler(request):
    if request.method == "GET":
        try: 
            page = request.GET.get("page",1)
            limit = request.GET.get("limit",10)
            
            if page is None:
                page = 1
            if limit is None:
                limit = 10

            database.cur.execute("""
                SELECT get_users(%s, %s);
            """, (page, limit))

            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "message": result["status"] == "failed" and "User retrieval failed" or "User retrieved successfully",
                    "data": result
                },
                status = result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )


        except (Exception, database.Error) as error:
            database.conn.commit()

            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status = status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "POST":
        try:
            body = json.dumps(json.loads(request.body))

            database.cur.execute("""
                SELECT create_user(%s);
            """, (body,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "User creation failed" or "User created successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_201_CREATED
            )
        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

@api_view(['GET', 'PATCH', 'DELETE'])
def UserHandler(request, id):
    if request.method == "GET":
        try:
            database.cur.execute("""
                SELECT get_user(%s);
            """, (id,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "message": result["status"] == "failed" and "User retrieval failed" or "User retrieved successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "PATCH":
        try:
            body = json.dumps(json.loads(request.body))
            database.cur.execute("""
                SELECT update_user(%s, %s);
            """, (id, body))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "User update failed" or "User updated successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "DELETE":
        try:
            database.cur.execute("""
                SELECT delete_user(%s);
            """, (id,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "User deletion failed" or "User deleted successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    else:
        return Response(
            {"message": f"Invalid request method {request.method}"},
            status=status.HTTP_405_METHOD_NOT_ALLOWED
        )
        
@api_view(['GET', 'POST'])
def PublishersHandler(request):
    if request.method == "GET":
        try: 
            page = request.GET.get("page",1)
            limit = request.GET.get("limit",10)
            
            if page is None:
                page = 1
            if limit is None:
                limit = 10

            database.cur.execute("""
                SELECT get_publishers(%s, %s);
            """, (page, limit))

            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "message": result["status"] == "failed" and "Publisher retrieval failed" or "Publisher retrieved successfully",
                    "data": result
                },
                status = result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )


        except (Exception, database.Error) as error:
            database.conn.commit()

            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status = status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "POST":
        try:
            body = json.dumps(json.loads(request.body))

            database.cur.execute("""
                SELECT create_publisher(%s);
            """, (body,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Publisher creation failed" or "Publisher created successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_201_CREATED
            )
        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
@api_view(['GET', 'PATCH', 'DELETE'])
def PublisherHandler(request, id):
    if request.method == "GET":
        try:
            database.cur.execute("""
                SELECT get_publisher(%s);
            """, (id,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "message": result["status"] == "failed" and "Publisher retrieval failed" or "Publisher retrieved successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "PATCH":
        try:
            body = json.dumps(json.loads(request.body))
            database.cur.execute("""
                SELECT update_publisher(%s, %s);
            """, (id, body))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Publisher update failed" or "Publisher updated successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "DELETE":
        try:
            database.cur.execute("""
                SELECT delete_publisher(%s);
            """, (id,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Publisher deletion failed" or "Publisher deleted successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
    else:
        return Response(
            {"message": f"Invalid request method {request.method}"},
            status=status.HTTP_405_METHOD_NOT_ALLOWED
        )
        
@api_view(['GET', 'POST'])
def CategoriesHandler(request):
    if request.method == "GET":
        try: 
            page = request.GET.get("page",1)
            limit = request.GET.get("limit",10)
            
            if page is None:
                page = 1
            if limit is None:
                limit = 10

            database.cur.execute("""
                SELECT get_categories(%s, %s);
            """, (page, limit))

            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "message": result["status"] == "failed" and "Category retrieval failed" or "Category retrieved successfully",
                    "data": result
                },
                status = result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )


        except (Exception, database.Error) as error:
            database.conn.commit()

            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status = status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "POST":
        try:
            body = json.dumps(json.loads(request.body))

            database.cur.execute("""
                SELECT create_category(%s);
            """, (body,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Category creation failed" or "Category created successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_201_CREATED
            )
        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
@api_view(['GET', 'PATCH', 'DELETE'])
def CategoryHandler(request, id):
    if request.method == "GET":
        try:
            database.cur.execute("""
                SELECT get_category(%s);
            """, (id,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "message": result["status"] == "failed" and "Category retrieval failed" or "Category retrieved successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "PATCH":
        try:
            body = json.dumps(json.loads(request.body))
            database.cur.execute("""
                SELECT update_category(%s, %s);
            """, (id, body))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Category update failed" or "Category updated successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "DELETE":
        try:
            database.cur.execute("""
                SELECT delete_category(%s);
            """, (id,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Category deletion failed" or "Category deleted successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
    else:
        return Response(
            {"message": f"Invalid request method {request.method}"},
            status=status.HTTP_405_METHOD_NOT_ALLOWED
        )
        
@api_view(['GET', 'POST'])
def BooksHandler(request):
    if request.method == "GET":
        try: 
            page = request.GET.get("page",1)
            limit = request.GET.get("limit",10)
            
            if page is None:
                page = 1
            if limit is None:
                limit = 10

            database.cur.execute("""
                SELECT get_books(%s, %s);
            """, (page, limit))

            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "message": result["status"] == "failed" and "Book retrieval failed" or "Book retrieved successfully",
                    "data": result
                },
                status = result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )


        except (Exception, database.Error) as error:
            database.conn.commit()

            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status = status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "POST":
        try:
            body = json.dumps(json.loads(request.body))

            database.cur.execute("""
                SELECT create_book(%s);
            """, (body,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Book creation failed" or "Book created successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_201_CREATED
            )
        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
@api_view(['GET', 'PATCH', 'DELETE'])
def BookHandler(request, id):
    if request.method == "GET":
        try:
            database.cur.execute("""
                SELECT get_book(%s);
            """, (id,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "message": result["status"] == "failed" and "Book retrieval failed" or "Book retrieved successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "PATCH":
        try:
            body = json.dumps(json.loads(request.body))
            database.cur.execute("""
                SELECT update_book(%s, %s);
            """, (id, body))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Book update failed" or "Book updated successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "DELETE":
        try:
            database.cur.execute("""
                SELECT delete_book(%s);
            """, (id,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Book deletion failed" or "Book deleted successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
    else:
        return Response(
            {"message": f"Invalid request method {request.method}"},
            status=status.HTTP_405_METHOD_NOT_ALLOWED
        )
        
@api_view(['GET', 'POST'])
def ReviewsHandler(request):
    if request.method == "GET":
        try: 
            page = request.GET.get("page",1)
            limit = request.GET.get("limit",10)
            
            if page is None:
                page = 1
            if limit is None:
                limit = 10

            database.cur.execute("""
                SELECT get_reviews(%s, %s);
            """, (page, limit))

            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "message": result["status"] == "failed" and "Review retrieval failed" or "Review retrieved successfully",
                    "data": result
                },
                status = result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )


        except (Exception, database.Error) as error:
            database.conn.commit()

            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status = status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "POST":
        try:
            body = json.dumps(json.loads(request.body))

            database.cur.execute("""
                SELECT create_review(%s);
            """, (body,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Review creation failed" or "Review created successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_201_CREATED
            )
        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
@api_view(['GET', 'PATCH', 'DELETE'])
def ReviewHandler(request, id):
    if request.method == "GET":
        try:
            database.cur.execute("""
                SELECT get_review(%s);
            """, (id,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "message": result["status"] == "failed" and "Review retrieval failed" or "Review retrieved successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "PATCH":
        try:
            body = json.dumps(json.loads(request.body))
            database.cur.execute("""
                SELECT update_review(%s, %s);
            """, (id, body))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Review update failed" or "Review updated successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "DELETE":
        try:
            database.cur.execute("""
                SELECT delete_review(%s);
            """, (id,))
            
            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            database.conn.commit()
            return Response(
                {
                    "message": result["status"] == "failed" and "Review deletion failed" or "Review deleted successfully",
                    "data": result
                },
                status=result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )

        except (Exception, database.Error) as error:
            database.conn.commit()
            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
    else:
        return Response(
            {"message": f"Invalid request method {request.method}"},
            status=status.HTTP_405_METHOD_NOT_ALLOWED
        )
        
        
