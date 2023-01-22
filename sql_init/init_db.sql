-- Table: public.depots

-- DROP TABLE IF EXISTS public.depots;

CREATE TABLE IF NOT EXISTS public.depots
(
    id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    owner_id uuid NOT NULL DEFAULT current_userid(),
    name character varying COLLATE pg_catalog."default" NOT NULL,
    "number" character varying COLLATE pg_catalog."default" NOT NULL,
    notes text COLLATE pg_catalog."default",
    CONSTRAINT depots_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.depots
    OWNER to postgres;

ALTER TABLE IF EXISTS public.depots
    ENABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.depots TO anon;

GRANT ALL ON TABLE public.depots TO authenticated;

GRANT ALL ON TABLE public.depots TO postgres;

CREATE POLICY "Only your data"
    ON public.depots
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((current_userid() = owner_id));
	
-- Table: public.depot_exports

-- DROP TABLE IF EXISTS public.depot_exports;

CREATE TABLE IF NOT EXISTS public.depot_exports
(
    id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    name text COLLATE pg_catalog."default" NOT NULL,
    export_time timestamp without time zone NOT NULL,
    "number" text COLLATE pg_catalog."default" NOT NULL,
    owner_id uuid NOT NULL DEFAULT current_userid(),
    win_loss_amount double precision NOT NULL,
    win_loss_percent double precision NOT NULL,
    depot_id uuid NOT NULL,
    total_spent double precision NOT NULL,
    CONSTRAINT depot_exports_pkey PRIMARY KEY (id),
    CONSTRAINT export_to_depots FOREIGN KEY (depot_id)
        REFERENCES public.depots (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.depot_exports
    OWNER to postgres;

ALTER TABLE IF EXISTS public.depot_exports
    ENABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.depot_exports TO anon;

GRANT ALL ON TABLE public.depot_exports TO authenticated;

GRANT ALL ON TABLE public.depot_exports TO postgres;

COMMENT ON TABLE public.depot_exports
    IS 'List of all exports for a depot';
-- POLICY: You can only see,edit your own data

-- DROP POLICY IF EXISTS "You can only see,edit your own data" ON public.depot_exports;

CREATE POLICY "You can only see,edit your own data"
    ON public.depot_exports
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((current_userid() = owner_id));
	
	
-- Table: public.depot_items

-- DROP TABLE IF EXISTS public.depot_items;

CREATE TABLE IF NOT EXISTS public.depot_items
(
    id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    owner_id uuid NOT NULL DEFAULT current_userid(),
    tags text[] COLLATE pg_catalog."default",
    isin text COLLATE pg_catalog."default" NOT NULL,
    depot_id uuid NOT NULL,
    note text COLLATE pg_catalog."default",
    name text COLLATE pg_catalog."default" NOT NULL,
    last_total_value double precision NOT NULL DEFAULT '0'::double precision,
    last_win_loss double precision NOT NULL DEFAULT '0'::double precision,
    last_win_loss_percent double precision NOT NULL DEFAULT '0'::double precision,
    active boolean NOT NULL DEFAULT true,
    CONSTRAINT depot_items_pkey PRIMARY KEY (id),
    CONSTRAINT line_items_depot FOREIGN KEY (depot_id)
        REFERENCES public.depots (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.depot_items
    OWNER to postgres;

ALTER TABLE IF EXISTS public.depot_items
    ENABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.depot_items TO anon;

GRANT ALL ON TABLE public.depot_items TO authenticated;

GRANT ALL ON TABLE public.depot_items TO postgres;
-- POLICY: Only your data

-- DROP POLICY IF EXISTS "Only your data" ON public.depot_items;

CREATE POLICY "Only your data"
    ON public.depot_items
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((current_userid() = owner_id));
	
-- Table: public.line_items

-- DROP TABLE IF EXISTS public.line_items;

CREATE TABLE IF NOT EXISTS public.line_items
(
    id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
    created_at timestamp with time zone DEFAULT now(),
    export_id uuid NOT NULL,
    isin text COLLATE pg_catalog."default" NOT NULL,
    name text COLLATE pg_catalog."default" NOT NULL,
    amount double precision NOT NULL,
    amount_type text COLLATE pg_catalog."default" NOT NULL,
    single_purchase_price double precision NOT NULL,
    currency text COLLATE pg_catalog."default" NOT NULL,
    total_purchase_price double precision NOT NULL,
    current_value double precision NOT NULL,
    export_time text COLLATE pg_catalog."default" NOT NULL,
    market_name text COLLATE pg_catalog."default" NOT NULL,
    current_total_value double precision NOT NULL,
    current_win_loss double precision NOT NULL,
    current_win_loss_percent double precision NOT NULL,
    owner_id uuid NOT NULL DEFAULT current_userid(),
    depot_item uuid NOT NULL,
    CONSTRAINT line_items_pkey PRIMARY KEY (id),
    CONSTRAINT export_to_line_items FOREIGN KEY (export_id)
        REFERENCES public.depot_exports (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT line_items_depot_item_fkey FOREIGN KEY (depot_item)
        REFERENCES public.depot_items (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.line_items
    OWNER to postgres;

ALTER TABLE IF EXISTS public.line_items
    ENABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.line_items TO anon;

GRANT ALL ON TABLE public.line_items TO authenticated;

GRANT ALL ON TABLE public.line_items TO postgres;

COMMENT ON TABLE public.line_items
    IS 'All line items for a given export';
-- POLICY: You can only see,edit your own data

-- DROP POLICY IF EXISTS "You can only see,edit your own data" ON public.line_items;

CREATE POLICY "You can only see,edit your own data"
    ON public.line_items
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((current_userid() = owner_id));
	
-- Table: public.dividends

-- DROP TABLE IF EXISTS public.dividends;

CREATE TABLE IF NOT EXISTS public.dividends
(
    id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    owner_id uuid NOT NULL DEFAULT current_userid(),
    depot_id uuid NOT NULL,
    depot_item_id uuid NOT NULL,
    amount double precision NOT NULL,
    booked_at timestamp without time zone NOT NULL,
    CONSTRAINT dividends_pkey PRIMARY KEY (id),
    CONSTRAINT dividends_depot_id_fkey FOREIGN KEY (depot_id)
        REFERENCES public.depots (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT dividends_depot_item_id_fkey FOREIGN KEY (depot_item_id)
        REFERENCES public.depot_items (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.dividends
    OWNER to postgres;

ALTER TABLE IF EXISTS public.dividends
    ENABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.dividends TO anon;

GRANT ALL ON TABLE public.dividends TO authenticated;

GRANT ALL ON TABLE public.dividends TO postgres;

CREATE POLICY "You can only see,edit your own data"
    ON public.dividends
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((current_userid() = owner_id));
	

-- FUNCTION: public.depotlinetable(uuid, text, boolean)

-- DROP FUNCTION IF EXISTS public.depotlinetable(uuid, text, boolean);

CREATE OR REPLACE FUNCTION public.depotlinetable(
	depotidfilter uuid,
	filter text DEFAULT NULL::text,
	activeonly boolean DEFAULT true)
    RETURNS TABLE(id uuid, owner_id uuid, created_at timestamp with time zone, depot_id uuid, name text, isin text, note text, tags text[], 
				  last_total_value double precision, last_win_loss double precision, last_win_loss_percent double precision, active boolean) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
SELECT 
      depot_items.id,
      depot_items.owner_id,
      depot_items.created_at,
      depot_items.depot_id,
      depot_items.name,
      depot_items.isin,
      depot_items.note,
      depot_items.tags,
      depot_items.last_total_value,
      depot_items.last_win_loss,
      depot_items.last_win_loss_percent,
      depot_items.active
FROM depot_items
WHERE 
      depot_items.depot_id = depotIdfilter 
      AND ( filter IS null 
            OR depot_items.isin ILIKE '%'||filter||'%' 
            OR  0 < (
                      SELECT COUNT(*) 
                      FROM unnest(depot_items.tags) AS itemtags
                      WHERE itemtags ILIKE '%'||filter||'%'
                    )
  )
  AND (active = activeonly OR activeonly = false)
$BODY$;

ALTER FUNCTION public.depotlinetable(uuid, text, boolean)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.depotlinetable(uuid, text, boolean) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.depotlinetable(uuid, text, boolean) TO anon;

GRANT EXECUTE ON FUNCTION public.depotlinetable(uuid, text, boolean) TO authenticated;

GRANT EXECUTE ON FUNCTION public.depotlinetable(uuid, text, boolean) TO postgres;


-- FUNCTION: public.getdepotchart(uuid)

-- DROP FUNCTION IF EXISTS public.getdepotchart(uuid);

CREATE OR REPLACE FUNCTION public.getdepotchart(
	depotid uuid)
    RETURNS TABLE(export_time timestamp without time zone, win_loss_amount double precision, totalinvest double precision) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
SELECT 
    depot_exports.export_time,
    depot_exports.win_loss_amount,
    (SELECT SUM(line_items.total_purchase_price) FROM line_items WHERE export_id = depot_exports.id) as totalinvest
    FROM depot_exports
    WHERE depot_id = depotid
    ORDER BY  depot_exports.export_time ASC
$BODY$;

ALTER FUNCTION public.getdepotchart(uuid)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.getdepotchart(uuid) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.getdepotchart(uuid) TO anon;

GRANT EXECUTE ON FUNCTION public.getdepotchart(uuid) TO authenticated;

GRANT EXECUTE ON FUNCTION public.getdepotchart(uuid) TO postgres;

-- FUNCTION: public.getdepotchartbyline(uuid, character varying[])

-- DROP FUNCTION IF EXISTS public.getdepotchartbyline(uuid, character varying[]);

CREATE OR REPLACE FUNCTION public.getdepotchartbyline(
	depotid uuid,
	isinf character varying[])
    RETURNS TABLE(export_time timestamp without time zone, win_loss_amount double precision, totalinvest double precision) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
SELECT 
    depot_exports.export_time,
    (SELECT SUM(line_items.current_win_loss) FROM line_items WHERE export_id = depot_exports.id AND line_items.isin = ANY(isinf)) as win_loss_amount,
    (SELECT SUM(line_items.total_purchase_price) FROM line_items WHERE export_id = depot_exports.id AND line_items.isin = ANY(isinf)) as totalinvest
    FROM depot_exports
    WHERE depot_id = depotid 
    ORDER BY  depot_exports.export_time ASC
$BODY$;

ALTER FUNCTION public.getdepotchartbyline(uuid, character varying[])
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.getdepotchartbyline(uuid, character varying[]) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.getdepotchartbyline(uuid, character varying[]) TO anon;

GRANT EXECUTE ON FUNCTION public.getdepotchartbyline(uuid, character varying[]) TO authenticated;

GRANT EXECUTE ON FUNCTION public.getdepotchartbyline(uuid, character varying[]) TO postgres;

-- FUNCTION: public.getdepotstats(uuid)

-- DROP FUNCTION IF EXISTS public.getdepotstats(uuid);

CREATE OR REPLACE FUNCTION public.getdepotstats(
	depotid uuid DEFAULT NULL::uuid)
    RETURNS TABLE(id uuid, name character varying, number character varying, owner_id uuid, created_at timestamp with time zone, totalexports bigint, totalgainloss double precision, totalgainlosspercent double precision, notes text, export_time timestamp without time zone) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
SELECT depots.id,depots.name,depots.number,depots.owner_id,depots.created_at,
    (SELECT COUNT(*) FROM depot_exports WHERE depot_exports.depot_id= depots.id) as totlaExports,
    lastExport.win_loss_amount as totalGainLoss,
    lastExport.win_loss_percent as totalGainLossPercent,
    depots.notes,
    lastExport.export_time
FROM depots
JOIN LATERAL (     
              SELECT * FROM depot_exports 
              WHERE depot_exports.depot_id = depots.id  
              ORDER BY export_time DESC LIMIT 1) lastExport ON TRUE
WHERE depotId IS NULL OR depots.id = depotId
ORDER BY depots.name;
$BODY$;

ALTER FUNCTION public.getdepotstats(uuid)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.getdepotstats(uuid) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.getdepotstats(uuid) TO anon;

GRANT EXECUTE ON FUNCTION public.getdepotstats(uuid) TO authenticated;

GRANT EXECUTE ON FUNCTION public.getdepotstats(uuid) TO postgres;

-- FUNCTION: public.totallineitemsforlastexport(uuid)

-- DROP FUNCTION IF EXISTS public.totallineitemsforlastexport(uuid);

CREATE OR REPLACE FUNCTION public.totallineitemsforlastexport(
	depotid uuid)
    RETURNS bigint
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
SELECT  COUNT(*) FROM line_items
WHERE line_items.export_id = 
(SELECT depot_exports.id FROM depot_exports WHERE depot_exports.depot_id= depotid ORDER BY depot_exports.export_time DESC LIMIT 1)
$BODY$;

ALTER FUNCTION public.totallineitemsforlastexport(uuid)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.totallineitemsforlastexport(uuid) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.totallineitemsforlastexport(uuid) TO anon;

GRANT EXECUTE ON FUNCTION public.totallineitemsforlastexport(uuid) TO authenticated;

GRANT EXECUTE ON FUNCTION public.totallineitemsforlastexport(uuid) TO postgres;

-- FUNCTION: public.updatedepotitems(character varying[])

-- DROP FUNCTION IF EXISTS public.updatedepotitems(character varying[]);

CREATE OR REPLACE FUNCTION public.updatedepotitems(
	isinfilter character varying[])
    RETURNS integer
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

 UPDATE depot_items SET last_total_value = (SELECT line_items.total_purchase_price FROM line_items WHERE line_items.depot_item = depot_items.id AND export_id = (SELECT id FROM depot_exports WHERE depot_exports.depot_id = depot_items.depot_id ORDER BY export_time DESC LIMIT 1))
 WHERE depot_items.isin = ANY(isinFilter);
  
  UPDATE depot_items SET last_win_loss = (SELECT line_items.current_win_loss FROM line_items WHERE line_items.depot_item = depot_items.id AND export_id = (SELECT id FROM depot_exports WHERE depot_exports.depot_id = depot_items.depot_id ORDER BY export_time DESC LIMIT 1))
  WHERE depot_items.isin = ANY(isinFilter);
   
   UPDATE depot_items SET last_win_loss_percent = (SELECT line_items.current_win_loss_percent FROM line_items WHERE line_items.depot_item = depot_items.id AND export_id = (SELECT id FROM depot_exports WHERE depot_exports.depot_id = depot_items.depot_id ORDER BY export_time DESC LIMIT 1))
   WHERE depot_items.isin = ANY(isinFilter);
  SELECT 1;
$BODY$;

ALTER FUNCTION public.updatedepotitems(character varying[])
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.updatedepotitems(character varying[]) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.updatedepotitems(character varying[]) TO anon;

GRANT EXECUTE ON FUNCTION public.updatedepotitems(character varying[]) TO authenticated;

GRANT EXECUTE ON FUNCTION public.updatedepotitems(character varying[]) TO postgres;









