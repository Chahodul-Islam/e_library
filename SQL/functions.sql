DROP FUNCTION IF EXISTS create_user;
CREATE OR REPLACE FUNCTION create_user(data JSON)
RETURNS JSON AS $$
DECLARE
	_user JSON = NULL::JSON;
	_name VARCHAR = coalesce((data->>'name')::varchar, NULL);
	_email VARCHAR = coalesce((data->>'email')::varchar, NULL);
    _username VARCHAR = coalesce((data->>'username')::varchar, NULL);
    _password VARCHAR = coalesce((data->>'password')::varchar, NULL);
BEGIN
	IF _username IS NULL OR _name IS NULL OR _email IS NULL OR _password IS NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'message', 'All fields are required'
		);
	END IF;

	INSERT INTO users (name, email, username, password)
	VALUES (_name, _email, _username, _password)
	RETURNING JSON_BUILD_OBJECT(
		'id', id,
		'name', name,
        'email', email,
        'username', username
	) INTO _user;

	RETURN JSON_BUILD_OBJECT(
		'status', CASE WHEN _user IS NULL THEN 'failed' ELSE 'success' END,
		'user', _user
	);
END;
$$ LANGUAGE plpgsql;

-- get_users
DROP FUNCTION IF EXISTS get_users;
CREATE OR REPLACE FUNCTION get_users(_page INT, _limit INT)
RETURNS JSON AS $$
DECLARE
	_users JSON = NULL::JSON;
	_page INT = coalesce(_page, 1);
	_limit INT = coalesce(_limit, 10);
BEGIN
	_users = (
		select JSON_AGG(JSON_BUILD_OBJECT(
			'id', uu.id,
			'name', uu.name,
            'email', uu.email,
            'username', uu.username,
            'password', uu.password
		))
		FROM (
			SELECT 
				u.id,
                u.name,
                u.email,
                u.username,
                u.password
			FROM users u
			ORDER BY u.id ASC
			LIMIT _limit
			OFFSET (_page - 1) * _limit
		) uu
	)::JSON;
	return JSON_BUILD_OBJECT(
		'status', 'success',
		'users', _users
	);
END;
$$ LANGUAGE plpgsql;

--get_user(S)

DROP FUNCTION IF EXISTS get_user;
CREATE OR REPLACE FUNCTION get_user(_id INT)
RETURNS JSON AS $$
DECLARE
	_user JSON = NULL::JSON;
BEGIN
	IF _id IS NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'id', 'required'
		);
	END IF;
	
	_user = (
		SELECT JSON_AGG(u) 
		FROM users u
		WHERE id = _id
	)::JSON -> 0;
	
	RETURN JSON_BUILD_OBJECT(
		'status', CASE WHEN _user IS NULL THEN 'failed' ELSE 'success' END,
		'user', _user
	);
END;
$$ LANGUAGE plpgsql;

-- update_user

DROP FUNCTION IF EXISTS update_user;
CREATE OR REPLACE FUNCTION update_user(user_id INT, data JSON)
RETURNS JSON AS $$
DECLARE
	_user JSON = NULL::JSON;
    _name VARCHAR = coalesce((data->>'name')::varchar, NULL);
    _email VARCHAR = coalesce((data->>'email')::varchar, NULL);
    _username VARCHAR = coalesce((data->>'username')::varchar, NULL);
    _password VARCHAR = coalesce((data->>'password')::varchar, NULL);
BEGIN
	IF _name IS NULL AND _email IS NULL AND _username IS NULL AND _password is NULL THEN
		RETURN JSON_BUILD_OBJECT(
			'status', 'failed',
			'message', 'At least one field is required for updating'
		);
	END IF;

	UPDATE users
	SET
		name = coalesce(_name, name),
        email = coalesce(_email, email),
        username = coalesce(_username, username),
        password = coalesce(_password, password)
	WHERE id = user_id
	RETURNING JSON_BUILD_OBJECT(
		'id', id,
		'name', name,
        'email', email,
        'username', username,
        'password', password
	) INTO _user;

	RETURN JSON_BUILD_OBJECT(
		'status', CASE WHEN _user IS NULL THEN 'failed' ELSE 'success' END,
		'user', _user
	);
END;
$$ LANGUAGE plpgsql;

-- delete_users

DROP FUNCTION IF EXISTS delete_user;
CREATE OR REPLACE FUNCTION delete_user(user_id INT)
RETURNS JSON AS $$
DECLARE
	_user JSON = NULL::JSON;
BEGIN
	DELETE FROM users WHERE id = user_id
	RETURNING JSON_BUILD_OBJECT(
		'id', id,
		'name', name,
        'email', email,
        'username', username,
        'password', password
	) INTO _user;

	RETURN JSON_BUILD_OBJECT(
		'status', CASE WHEN _user IS NULL THEN 'failed' ELSE 'success' END,
		'user', _user
	);
END;
$$ LANGUAGE plpgsql;

-- create_publisher

DROP FUNCTION IF EXISTS create_publisher;
CREATE OR REPLACE FUNCTION create_publisher(data JSON)
RETURNS JSON AS $$
DECLARE
    _publisher JSON = NULL::JSON;
    _name VARCHAR = coalesce((data->>'name')::varchar, NULL);
    _contract VARCHAR = coalesce((data->>'contract')::varchar, NULL);
BEGIN

    IF _name IS NULL OR _contract IS NULL THEN
        RETURN JSON_BUILD_OBJECT(
            'status', 'failed',
            'message', 'All fields are required'
        );
    END IF;

    INSERT INTO publishers (name, contract)
    VALUES (_name, _contract)
    RETURNING JSON_BUILD_OBJECT(
        'id', id,
        'name', name,
        'contract', contract
    ) INTO _publisher;

    RETURN JSON_BUILD_OBJECT(
        'status', CASE WHEN _publisher IS NULL THEN 'failed' ELSE 'success' END,
        'publisher', _publisher
    );
END;
$$ LANGUAGE plpgsql;

-- get_publishers

DROP FUNCTION IF EXISTS get_publishers;
CREATE OR REPLACE FUNCTION get_publishers(_page INT, _limit INT)
RETURNS JSON AS $$
DECLARE
    _publishers JSON = NULL::JSON;
    _page INT = coalesce(_page, 1);
    _limit INT = coalesce(_limit, 10);
BEGIN
    _publishers = (
        select JSON_AGG(JSON_BUILD_OBJECT(
            'id', pp.id,
            'name', pp.name,
            'contract', pp.contract
        ))
        FROM (
            SELECT 
                p.id,
                p.name,
                p.contract
            FROM publishers p
            ORDER BY p.id ASC
            LIMIT _limit
            OFFSET (_page - 1) * _limit
        ) pp
    )::JSON;
    return JSON_BUILD_OBJECT(
        'status', 'success',
        'publishers', _publishers
    );
END;
$$ LANGUAGE plpgsql;

-- get_publisher

DROP FUNCTION IF EXISTS get_publisher;
CREATE OR REPLACE FUNCTION get_publisher(publisher_id INT)
RETURNS JSON AS $$
DECLARE
    _publisher JSON = NULL::JSON;
BEGIN

    IF publisher_id IS NULL THEN
        RETURN JSON_BUILD_OBJECT(
            'status', 'failed',
            'publisher_id', 'required'
        );
    END IF;
    
    _publisher = (
        SELECT JSON_AGG(p) 
        FROM publishers p
        WHERE id = publisher_id
    )::JSON -> 0;
    
    RETURN JSON_BUILD_OBJECT(
        'status', CASE WHEN _publisher IS NULL THEN 'failed' ELSE 'success' END,
        'publisher', _publisher
    );
END;
$$ LANGUAGE plpgsql;

-- update_publisher

DROP FUNCTION IF EXISTS update_publisher;
CREATE OR REPLACE FUNCTION update_publisher(publisher_id INT, data JSON)
RETURNS JSON AS $$
DECLARE
    _publisher JSON = NULL::JSON;
    _name VARCHAR = coalesce((data->>'name')::varchar, NULL);
    _contract VARCHAR = coalesce((data->>'contract')::varchar, NULL);
BEGIN
    IF _name IS NULL AND _contract IS NULL THEN
        RETURN JSON_BUILD_OBJECT(
            'status', 'failed',
            'message', 'At least one field is required for updating'
        );
    END IF;

    UPDATE publishers
    SET
        name = coalesce(_name, name),
        contract = coalesce(_contract, contract)
    WHERE id = publisher_id

    RETURNING JSON_BUILD_OBJECT(
        'id', id,
        'name', name,
        'contract', contract
    ) INTO _publisher;

    RETURN JSON_BUILD_OBJECT(
        'status', CASE WHEN _publisher IS NULL THEN 'failed' ELSE 'success' END,
        'publisher', _publisher
    );
END;
$$ LANGUAGE plpgsql;

-- delete_publisher

DROP FUNCTION IF EXISTS delete_publisher;
CREATE OR REPLACE FUNCTION delete_publisher(publisher_id INT)
RETURNS JSON AS $$
DECLARE
    _publisher JSON = NULL::JSON;
BEGIN

    DELETE FROM publishers WHERE id = publisher_id
    RETURNING JSON_BUILD_OBJECT(
        'id', id,
        'name', name,
        'contract', contract
    ) INTO _publisher;

    RETURN JSON_BUILD_OBJECT(
        'status', CASE WHEN _publisher IS NULL THEN 'failed' ELSE 'success' END,
        'publisher', _publisher
    );
END;
$$ LANGUAGE plpgsql;

-- create_category

DROP FUNCTION IF EXISTS create_category;
CREATE OR REPLACE FUNCTION create_category(data JSON)
RETURNS JSON AS $$
DECLARE
    _category JSON = NULL::JSON;
    _genre_name VARCHAR = coalesce((data->>'genre_name')::varchar, NULL);
BEGIN
    
        IF _genre_name IS NULL THEN
            RETURN JSON_BUILD_OBJECT(
                'status', 'failed',
                'message', 'All fields are required'
            );
        END IF;
    
        INSERT INTO categories (genre_name)
        VALUES (_genre_name)
        RETURNING JSON_BUILD_OBJECT(
            'id', id,
            'genre_name', genre_name
        ) INTO _category;
    
        RETURN JSON_BUILD_OBJECT(
            'status', CASE WHEN _category IS NULL THEN 'failed' ELSE 'success' END,
            'category', _category
        );
    END;
$$ LANGUAGE plpgsql;

-- get_categories

DROP FUNCTION IF EXISTS get_categories;
CREATE OR REPLACE FUNCTION get_categories(_page INT, _limit INT)
RETURNS JSON AS $$
DECLARE
    _categories JSON = NULL::JSON;
    _page INT = coalesce(_page, 1);
    _limit INT = coalesce(_limit, 10);
BEGIN

    _categories = (
        select JSON_AGG(JSON_BUILD_OBJECT(
            'id', cc.id,
            'genre_name', cc.genre_name
        ))
        FROM (
            SELECT 
                c.id,
                c.genre_name
            FROM categories c
            ORDER BY c.id ASC
            LIMIT _limit
            OFFSET (_page - 1) * _limit
        ) cc
    )::JSON;
    return JSON_BUILD_OBJECT(
        'status', 'success',
        'categories', _categories
    );
END;
$$ LANGUAGE plpgsql;

-- get_category

DROP FUNCTION IF EXISTS get_category;
CREATE OR REPLACE FUNCTION get_category(category_id INT)
RETURNS JSON AS $$
DECLARE
    _category JSON = NULL::JSON;
BEGIN
    
        IF category_id IS NULL THEN
            RETURN JSON_BUILD_OBJECT(
                'status', 'failed',
                'category_id', 'required'
            );
        END IF;
        
        _category = (
            SELECT JSON_AGG(c) 
            FROM categories c
            WHERE id = category_id
        )::JSON -> 0;
        
        RETURN JSON_BUILD_OBJECT(
            'status', CASE WHEN _category IS NULL THEN 'failed' ELSE 'success' END,
            'category', _category
        );
    END;

$$ LANGUAGE plpgsql;

-- update_category

DROP FUNCTION IF EXISTS update_category;
CREATE OR REPLACE FUNCTION update_category(category_id INT, data JSON)
RETURNS JSON AS $$
DECLARE
    _category JSON = NULL::JSON;
    _genre_name VARCHAR = coalesce((data->>'genre_name')::varchar, NULL);
BEGIN

    IF _genre_name IS NULL THEN
        RETURN JSON_BUILD_OBJECT(
            'status', 'failed',
            'message', 'At least one field is required for updating'
        );
    END IF;

    UPDATE categories
    SET
        genre_name = coalesce(_genre_name, genre_name)
    WHERE id = category_id

    RETURNING JSON_BUILD_OBJECT(
        'id', id,
        'genre_name', genre_name
    ) INTO _category;

    RETURN JSON_BUILD_OBJECT(
        'status', CASE WHEN _category IS NULL THEN 'failed' ELSE 'success' END,
        'category', _category
    );
END;
$$ LANGUAGE plpgsql;

-- delete_category

DROP FUNCTION IF EXISTS delete_category;
CREATE OR REPLACE FUNCTION delete_category(category_id INT)
RETURNS JSON AS $$
DECLARE
    _category JSON = NULL::JSON;
BEGIN
    DELETE FROM categories WHERE id = category_id
    RETURNING JSON_BUILD_OBJECT(
        'id', id,
        'genre_name', genre_name
    ) INTO _category;

    RETURN JSON_BUILD_OBJECT(
        'status', CASE WHEN _category IS NULL THEN 'failed' ELSE 'success' END,
        'category', _category
    );
END;
$$ LANGUAGE plpgsql;

-- create_book

DROP FUNCTION IF EXISTS create_book;
CREATE OR REPLACE FUNCTION create_book(data JSON)
RETURNS JSON AS $$
DECLARE
    _book JSON = NULL::JSON;
    _title VARCHAR = coalesce((data->>'title')::varchar, NULL);
    _isbn VARCHAR = coalesce((data->>'isbn')::varchar, NULL);
    _publisher_id INT = coalesce((data->>'publisher_id')::INT, NULL);
    _pub_date DATE = coalesce((data->>'pub_date')::DATE, NULL);
    _genre_id INT = coalesce((data->>'genre_id')::INT, NULL);
    _availability BOOLEAN = coalesce((data->>'availability')::BOOLEAN, NULL);
BEGIN
    
        IF _title IS NULL OR _isbn IS NULL OR _publisher_id IS NULL OR _pub_date IS NULL OR _genre_id IS NULL OR _availability IS NULL THEN
            RETURN JSON_BUILD_OBJECT(
                'status', 'failed',
                'message', 'All fields are required'
            );
        END IF;
    
        INSERT INTO books (title, isbn, publisher_id, pub_date, genre_id, availability)
        VALUES (_title, _isbn, _publisher_id, _pub_date, _genre_id, _availability)
        RETURNING JSON_BUILD_OBJECT(
            'id', id,
            'title', title,
            'isbn', isbn,
            'publisher_id', publisher_id,
            'pub_date', pub_date,
            'genre_id', genre_id,
            'availability', availability
        ) INTO _book;
    
        RETURN JSON_BUILD_OBJECT(
            'status', CASE WHEN _book IS NULL THEN 'failed' ELSE 'success' END,
            'book', _book
        );
    END;
$$ LANGUAGE plpgsql;

-- get_books

DROP FUNCTION IF EXISTS get_books;
CREATE OR REPLACE FUNCTION get_books(_page INT, _limit INT)
RETURNS JSON AS $$
DECLARE
    _books JSON = NULL::JSON;
    _page INT = coalesce(_page, 1);
    _limit INT = coalesce(_limit, 10);

BEGIN

    _books = (
        select JSON_AGG(JSON_BUILD_OBJECT(
            'id', bb.id,
            'title', bb.title,
            'isbn', bb.isbn,
            'publisher_id', bb.publisher_id,
            'pub_date', bb.pub_date,
            'genre_id', bb.genre_id,
            'availability', bb.availability
        ))
        FROM (
            SELECT 
                b.id,
                b.title,
                b.isbn,
                b.publisher_id,
                b.pub_date,
                b.genre_id,
                b.availability
            FROM books b
            ORDER BY b.id ASC
            LIMIT _limit
            OFFSET (_page - 1) * _limit
        ) bb
    )::JSON;
    return JSON_BUILD_OBJECT(
        'status', 'success',
        'books', _books
    );
END;
$$ LANGUAGE plpgsql;

-- get_book

DROP FUNCTION IF EXISTS get_book;
CREATE OR REPLACE FUNCTION get_book(book_id INT)
RETURNS JSON AS $$
DECLARE
    _book JSON = NULL::JSON;
BEGIN
    
        IF book_id IS NULL THEN
            RETURN JSON_BUILD_OBJECT(
                'status', 'failed',
                'book_id', 'required'
            );
        END IF;
        
        _book = (
            SELECT JSON_AGG(b) 
            FROM books b
            WHERE id = book_id
        )::JSON -> 0;
        
        RETURN JSON_BUILD_OBJECT(
            'status', CASE WHEN _book IS NULL THEN 'failed' ELSE 'success' END,
            'book', _book
        );
    END;

$$ LANGUAGE plpgsql;

-- update_book

DROP FUNCTION IF EXISTS update_book;
CREATE OR REPLACE FUNCTION update_book(book_id INT, data JSON)
RETURNS JSON AS $$
DECLARE
    _book JSON = NULL::JSON;
    _title VARCHAR = coalesce((data->>'title')::varchar, NULL);
    _isbn VARCHAR = coalesce((data->>'isbn')::varchar, NULL);
    _publisher_id INT = coalesce((data->>'publisher_id')::INT, NULL);
    _pub_date DATE = coalesce((data->>'pub_date')::DATE, NULL);
    _genre_id INT = coalesce((data->>'genre_id')::INT, NULL);
    _availability BOOLEAN = coalesce((data->>'availability')::BOOLEAN, NULL);
BEGIN
    
        IF _title IS NULL AND _isbn IS NULL AND _publisher_id IS NULL AND _pub_date IS NULL AND _genre_id IS NULL AND _availability IS NULL THEN
            RETURN JSON_BUILD_OBJECT(
                'status', 'failed',
                'message', 'At least one field is required for updating'
            );
        END IF;
    
        UPDATE books
        SET
            title = coalesce(_title, title),
            isbn = coalesce(_isbn, isbn),
            publisher_id = coalesce(_publisher_id, publisher_id),
            pub_date = coalesce(_pub_date, pub_date),
            genre_id = coalesce(_genre_id, genre_id),
            availability = coalesce(_availability, availability)
        WHERE id = book_id
    
        RETURNING JSON_BUILD_OBJECT(
            'id', id,
            'title', title,
            'isbn', isbn,
            'publisher_id', publisher_id,
            'pub_date', pub_date,
            'genre_id', genre_id,
            'availability', availability
        ) INTO _book;
    
        RETURN JSON_BUILD_OBJECT(
            'status', CASE WHEN _book IS NULL THEN 'failed' ELSE 'success' END,
            'book', _book
        );
    END;
$$ LANGUAGE plpgsql;

-- delete_book

DROP FUNCTION IF EXISTS delete_book;
CREATE OR REPLACE FUNCTION delete_book(book_id INT)
RETURNS JSON AS $$
DECLARE
    _book JSON = NULL::JSON;
BEGIN
    DELETE FROM books WHERE id = book_id
    RETURNING JSON_BUILD_OBJECT(
        'id', id,
        'title', title,
        'isbn', isbn,
        'publisher_id', publisher_id,
        'pub_date', pub_date,
        'genre_id', genre_id,
        'availability', availability
    ) INTO _book;

    RETURN JSON_BUILD_OBJECT(
        'status', CASE WHEN _book IS NULL THEN 'failed' ELSE 'success' END,
        'book', _book
    );
END;
$$ LANGUAGE plpgsql;

-- create_review

DROP FUNCTION IF EXISTS create_review;
CREATE OR REPLACE FUNCTION create_review(data JSON)
RETURNS JSON AS $$
DECLARE
    _review JSON = NULL::JSON;
    _userid INT = coalesce((data->>'userid')::INT, NULL);
    _book_id INT = coalesce((data->>'book_id')::INT, NULL);
    _review_text TEXT = coalesce((data->>'review_text')::TEXT, NULL);
    _rating INT = coalesce((data->>'rating')::INT, NULL);
BEGIN
    
        IF _userid IS NULL OR _book_id IS NULL OR _review_text IS NULL OR _rating IS NULL THEN
            RETURN JSON_BUILD_OBJECT(
                'status', 'failed',
                'message', 'All fields are required'
            );
        END IF;
    
        INSERT INTO reviews (userid, book_id, review_text, rating)
        VALUES (_userid, _book_id, _review_text, _rating)
        RETURNING JSON_BUILD_OBJECT(
            'id', id,
            'userid', userid,
            'book_id', book_id,
            'review_text', review_text,
            'rating', rating
        ) INTO _review;
    
        RETURN JSON_BUILD_OBJECT(
            'status', CASE WHEN _review IS NULL THEN 'failed' ELSE 'success' END,
            'review', _review
        );
    END;
$$ LANGUAGE plpgsql;

-- get_reviews

DROP FUNCTION IF EXISTS get_reviews;
CREATE OR REPLACE FUNCTION get_reviews(_page INT, _limit INT)
RETURNS JSON AS $$
DECLARE
    _reviews JSON = NULL::JSON;
    _page INT = coalesce(_page, 1);
    _limit INT = coalesce(_limit, 10);

BEGIN

    _reviews = (
        select JSON_AGG(JSON_BUILD_OBJECT(
            'id', rr.id,
            'userid', rr.userid,
            'book_id', rr.book_id,
            'review_text', rr.review_text,
            'rating', rr.rating
        ))
        FROM (
            SELECT 
                r.id,
                r.userid,
                r.book_id,
                r.review_text,
                r.rating
            FROM reviews r
            ORDER BY r.id ASC
            LIMIT _limit
            OFFSET (_page - 1) * _limit
        ) rr
    )::JSON;
    return JSON_BUILD_OBJECT(
        'status', 'success',
        'reviews', _reviews
    );
END;
$$ LANGUAGE plpgsql;

-- get_review

DROP FUNCTION IF EXISTS get_review;
CREATE OR REPLACE FUNCTION get_review(review_id INT)
RETURNS JSON AS $$
DECLARE
    _review JSON = NULL::JSON;
BEGIN
    
        IF review_id IS NULL THEN
            RETURN JSON_BUILD_OBJECT(
                'status', 'failed',
                'review_id', 'required'
            );
        END IF;
        
        _review = (
            SELECT JSON_AGG(r) 
            FROM reviews r
            WHERE id = review_id
        )::JSON -> 0;
        
        RETURN JSON_BUILD_OBJECT(
            'status', CASE WHEN _review IS NULL THEN 'failed' ELSE 'success' END,
            'review', _review
        );
    END;

$$ LANGUAGE plpgsql;

-- update_review

DROP FUNCTION IF EXISTS update_review;
CREATE OR REPLACE FUNCTION update_review(review_id INT, data JSON)
RETURNS JSON AS $$

DECLARE
    _review JSON = NULL::JSON;
    _userid INT = coalesce((data->>'userid')::INT, NULL);
    _book_id INT = coalesce((data->>'book_id')::INT, NULL);
    _review_text TEXT = coalesce((data->>'review_text')::TEXT, NULL);
    _rating INT = coalesce((data->>'rating')::INT, NULL);

BEGIN
    
        IF _userid IS NULL AND _book_id IS NULL AND _review_text IS NULL AND _rating IS NULL THEN
            RETURN JSON_BUILD_OBJECT(
                'status', 'failed',
                'message', 'At least one field is required for updating'
            );
        END IF;
    
        UPDATE reviews
        SET
            userid = coalesce(_userid, userid),
            book_id = coalesce(_book_id, book_id),
            review_text = coalesce(_review_text, review_text),
            rating = coalesce(_rating, rating)
        WHERE id = review_id
    
        RETURNING JSON_BUILD_OBJECT(
            'id', id,
            'userid', userid,
            'book_id', book_id,
            'review_text', review_text,
            'rating', rating
        ) INTO _review;
    
        RETURN JSON_BUILD_OBJECT(
            'status', CASE WHEN _review IS NULL THEN 'failed' ELSE 'success' END,
            'review', _review
        );
    END;
$$ LANGUAGE plpgsql;

-- delete_review

DROP FUNCTION IF EXISTS delete_review;
CREATE OR REPLACE FUNCTION delete_review(review_id INT)
RETURNS JSON AS $$
DECLARE
    _review JSON = NULL::JSON;
BEGIN
    DELETE FROM reviews WHERE id = review_id
    RETURNING JSON_BUILD_OBJECT(
        'id', id,
        'userid', userid,
        'book_id', book_id,
        'review_text', review_text,
        'rating', rating
    ) INTO _review;

    RETURN JSON_BUILD_OBJECT(
        'status', CASE WHEN _review IS NULL THEN 'failed' ELSE 'success' END,
        'review', _review
    );
END;
$$ LANGUAGE plpgsql;

