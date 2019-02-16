/* count table */

select 'links'   as "table name", count(1) as "row count" from "MOVIELENS"."workshop.helloworld.hdb::data.LINKS"
union all
select 'movies'  as "table name", count(1) as "row count" from "MOVIELENS"."workshop.helloworld.hdb::data.MOVIES"
union all
select 'ratings' as "table name", count(1) as "row count" from "MOVIELENS"."workshop.helloworld.hdb::data.RATINGS"
union all
select 'tags'    as "table name", count(1) as "row count" from "MOVIELENS"."workshop.helloworld.hdb::data.TAGS";

/* validate data in link table if it is existed in movies table */
select count(1)
from "MOVIELENS"."workshop.helloworld.hdb::data.LINKS" l
where not exists (select 1 from "MOVIELENS"."workshop.helloworld.hdb::data.MOVIES" m where l.movieid = m.movieid)
union all
select count(1)
from "MOVIELENS"."workshop.helloworld.hdb::data.MOVIES" m
where not exists (select 1 from "MOVIELENS"."workshop.helloworld.hdb::data.LINKS" l where l.movieid = m.movieid);

/* check genre to make sure it's valid */
select count(1)
from "MOVIELENS"."workshop.helloworld.hdb::data.MOVIES"
where genres is null or length(genres)=0;

select * from "MOVIELENS"."workshop.helloworld.hdb::data.MOVIES" limit 10;

do begin
  declare genrearray nvarchar(255) array;
  declare tmp nvarchar(255);
  declare idx integer;
  declare sep nvarchar(1) := '|';
  declare cursor cur for select distinct genres from "MOVIELENS"."workshop.helloworld.hdb::data.MOVIES";
  declare genres nvarchar (255) := '';
  idx := 1;
  for cur_row as cur() do
    select cur_row.genres into genres from dummy;
    tmp := :genres;
    while locate(:tmp,:sep) > 0 do
      genrearray[:idx] := substr_before(:tmp,:sep);
      tmp := substr_after(:tmp,:sep);
      idx := :idx + 1;
    end while;
    genrearray[:idx] := :tmp;
  end for;
  genrelist = unnest(:genrearray) as (genre);
  select genre, count(*) from :genrelist group by genre;
end;

/* count genre in a movie */
select
    movieid
  , title
  , occurrences_regexpr('[|]' in genres) + 1 as genre_count
  , genres
from "MOVIELENS"."workshop.helloworld.hdb::data.MOVIES"
order by genre_count asc;

select genre_count, count(1)
from (
	select occurrences_regexpr('[|]' in genres) + 1 as genre_count
	from "MOVIELENS"."workshop.helloworld.hdb::data.MOVIES"
)
group by genre_count order by genre_count desc;

/* count tag by movieid */
select count(1)
from (
  select movieid, count(1) as tag_count
  from "MOVIELENS"."workshop.helloworld.hdb::data.TAGS"
  group by movieid
);

/* count how many movie has 1 tag, 2 tags, etc */
select tag_count, count(1)
from (
  select movieid, count(1) as tag_count
  from "MOVIELENS"."workshop.helloworld.hdb::data.TAGS"
  group by movieid
)
group by tag_count order by tag_count;

/* count ratings per movie */
select rating_count, count(1) as movie_count
from (
  select movieid, count(1) as rating_count
  from "MOVIELENS"."workshop.helloworld.hdb::data.RATINGS"
  group by movieid
)
group by rating_count order by rating_count asc;

/* count rating by user */
select rating_count, count(1) as user_count
from (
  select userid, count(1) as rating_count
  from "MOVIELENS"."workshop.helloworld.hdb::data.RATINGS"
  group by userid
)
group by rating_count order by 1 desc;

select rating_count, count(1) as movie_count
from (
  select movieid, count(1) as rating_count
  from "MOVIELENS"."workshop.helloworld.hdb::data.RATINGS"
  group by  movieid
)
group by rating_count order by 1 desc;


select rating, count(1) as rating_count
from "MOVIELENS"."workshop.helloworld.hdb::data.RATINGS"
group by rating order by 1 desc;

select rating,  count(1) as users_count from (
  select userid, rating, count(1) as rating_count
  from "MOVIELENS"."workshop.helloworld.hdb::data.RATINGS"
  group by userid, rating
)
group by rating order by 1 desc;

select rating,  count(1) as movie_count from (
  select movieid, rating, count(1) as rating_count
  from "MOVIELENS"."workshop.helloworld.hdb::data.RATINGS"
  group by movieid, rating
)
group by rating order by 1 desc;

