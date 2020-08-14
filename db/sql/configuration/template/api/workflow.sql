--------------------------------------------------------------------------------
-- API WORKFLOW ----------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- ESSENCE ---------------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Сущность
 */
CREATE OR REPLACE VIEW api.essence
AS
  SELECT * FROM Essence;

GRANT SELECT ON api.essence TO administrator;

--------------------------------------------------------------------------------
-- api.get_essence -------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает сущность.
 * @return {record} - Запись
 */
CREATE OR REPLACE FUNCTION api.get_essence (
  pId     numeric
) RETURNS TABLE (
  id      numeric,
  code    varchar,
  name    varchar
)
AS $$
  SELECT e.id, e.code, e.name
    FROM api.essence e
   WHERE e.id = pId;
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- CLASS -----------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW api.class
AS
  SELECT * FROM ClassTree;

GRANT SELECT ON api.class TO administrator;

--------------------------------------------------------------------------------
-- api.add_class ---------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Создаёт класс.
 * @param {numeric} pParent - Идентификатор "родителя"
 * @param {numeric} pType - Идентификатор типа класса
 * @param {varchar} pCode - Код
 * @param {text} pLabel - Наименование
 * @param {boolean} pAbstract - Абстрактный (Да/Нет)
 * @return {numeric}
 */
CREATE OR REPLACE FUNCTION api.add_class (
  pParent     numeric,
  pType       numeric,
  pCode       varchar,
  pLabel      text,
  pAbstract   boolean DEFAULT true
) RETURNS     numeric
AS $$
BEGIN
  RETURN AddClass(pParent, pType, pCode, pLabel, pAbstract);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.update_class ------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Обновляет класс.
 * @param {numeric} pId - Идентификатор класса
 * @param {numeric} pParent - Идентификатор "родителя"
 * @param {numeric} pType - Идентификатор типа класса
 * @param {varchar} pCode - Код
 * @param {text} pLabel - Наименование
 * @param {boolean} pAbstract - Абстрактный (Да/Нет)
 * @out {numeric} id - Идентификатор класса
 * @out param {numeric} result - Результат
 * @out param {text} message - Текст ошибки
 * @return {record}
 */
CREATE OR REPLACE FUNCTION api.update_class (
  pId         numeric,
  pParent     numeric,
  pType       numeric,
  pCode       varchar,
  pLabel      text,
  pAbstract   boolean DEFAULT true
) RETURNS     void
AS $$
BEGIN
  PERFORM EditClass(pId, pParent, pType, pCode, pLabel, pAbstract);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.delete_class ------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Удаляет класс.
 * @param {numeric} pId - Идентификатор класса
 * @return {void}
 */
CREATE OR REPLACE FUNCTION api.delete_class (
  pId         numeric
) RETURNS     void
AS $$
BEGIN
  PERFORM DeleteClass(pId);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.get_class ---------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает класс.
 * @return {record} - Запись
 */
CREATE OR REPLACE FUNCTION api.get_class (
  pId       numeric
) RETURNS   SETOF api.class
AS $$
  SELECT * FROM api.class WHERE id = pId
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.list_class --------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает список классов.
 * @return {SETOF record} - Записи
 */
CREATE OR REPLACE FUNCTION api.list_class (
) RETURNS   SETOF api.class
AS $$
  SELECT * FROM api.class
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- STATE -----------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW api.state_type
AS
  SELECT * FROM StateType;

GRANT SELECT ON api.state_type TO administrator;

--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW api.state
AS
  SELECT * FROM State;

GRANT SELECT ON api.state TO administrator;

--------------------------------------------------------------------------------
-- api.get_state_type ----------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает тип состояния.
 * @return {record} - Запись
 */
CREATE OR REPLACE FUNCTION api.get_state_type (
  pId            numeric
) RETURNS        SETOF api.state_type
AS $$
  SELECT * FROM api.state_type WHERE id = pId;
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION api.state (
  pClass        numeric
) RETURNS       SETOF api.state
AS $$
  SELECT * FROM api.state WHERE class = pClass
  UNION ALL
  SELECT *
    FROM api.state
   WHERE id = GetState(pClass, code)
     AND id NOT IN (SELECT id FROM api.state WHERE class = pClass)
   ORDER BY sequence
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.add_state ---------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Создаёт состояние.
 * @param {numeric} pClass - Идентификатор класса
 * @param {numeric} pType - Идентификатор типа
 * @param {varchar} pCode - Код
 * @param {text} pLabel - Наименование
 * @param {integer} pSequence - Очередность
 * @out param {numeric} id - Идентификатор состояния
 * @out param {boolean} result - Результат
 * @out param {text} message - Текст ошибки
 * @return {record}
 */
CREATE OR REPLACE FUNCTION api.add_state (
  pClass      numeric,
  pType       numeric,
  pCode       varchar,
  pLabel      text,
  pSequence   integer
) RETURNS     numeric
AS $$
BEGIN
  RETURN AddState(pClass, pType, pCode, pLabel, pSequence);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.update_state ------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Обновляет состояние.
 * @param {numeric} pId - Идентификатор состояния
 * @param {numeric} pClass - Идентификатор класса
 * @param {numeric} pType - Идентификатор типа
 * @param {varchar} pCode - Код
 * @param {text} pLabel - Наименование
 * @param {integer} pSequence - Очередность
 * @out param {numeric} id - Идентификатор состояния
 * @out param {boolean} result - Результат
 * @out param {text} message - Текст ошибки
 * @return {record}
 */
CREATE OR REPLACE FUNCTION api.update_state (
  pId         numeric,
  pClass      numeric DEFAULT null,
  pType       numeric DEFAULT null,
  pCode       varchar DEFAULT null,
  pLabel      text DEFAULT null,
  pSequence   integer DEFAULT null
) RETURNS     void
AS $$
BEGIN
  PERFORM EditState(pId, pClass, pType, pCode, pLabel, pSequence);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.delete_state ------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Удаляет состояние.
 * @param {numeric} pId - Идентификатор состояния
 * @out param {numeric} id - Идентификатор состояния
 * @out param {numeric} result - Результат
 * @out param {text} message - Текст ошибки
 * @return {record}
 */
CREATE OR REPLACE FUNCTION api.delete_state (
  pId         numeric
) RETURNS     void
AS $$
BEGIN
  PERFORM DeleteState(pId);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.get_state ---------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает состояние.
 * @return {record} - Состояние
 */
CREATE OR REPLACE FUNCTION api.get_state (
  pId       numeric
) RETURNS   SETOF api.state
AS $$
  SELECT * FROM api.state WHERE id = pId
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.list_state --------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает список состояний.
 * @return {SETOF record} - Записи
 */
CREATE OR REPLACE FUNCTION api.list_state (
) RETURNS SETOF api.state
AS $$
  SELECT * FROM api.state
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- ACTION ----------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW api.action
AS
  SELECT * FROM Action;

GRANT SELECT ON api.action TO administrator;

--------------------------------------------------------------------------------
-- METHOD ----------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW api.method
AS
  SELECT * FROM Method;

GRANT SELECT ON api.method TO administrator;

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION api.method (
  pClass      numeric,
  pState      numeric
) RETURNS     SETOF api.method
AS $$
  SELECT * FROM api.method WHERE class = pClass AND coalesce(state, 0) = coalesce(pState, state, 0)
   UNION ALL
  SELECT *
    FROM api.method
   WHERE id = GetMethod(pClass, pState, action)
     AND id NOT IN (SELECT id FROM api.method WHERE class = pClass AND coalesce(state, 0) = coalesce(pState, state, 0))
   ORDER BY statecode, sequence
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.add_method --------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Создаёт метод (операцию).
 * @param {numeric} pParent - Идентификатор родителя (для создания вложенных методов, для построения меню)
 * @param {numeric} pClass - Идентификатор класса: api.class
 * @param {numeric} pState - Идентификатор состояния: api.state
 * @param {numeric} pAction - Идентификатор действия: api.action
 * @param {varchar} pCode - Код
 * @param {text} pLabel - Наименование
 * @param {integer} pSequence - Очередность
 * @param {boolean} pVisible - Видимый: Да/Нет
 * @return {numeric}
 */
CREATE OR REPLACE FUNCTION api.add_method (
  pParent       numeric,
  pClass        numeric,
  pState        numeric,
  pAction       numeric,
  pCode         varchar,
  pLabel        text,
  pSequence     integer,
  pVisible      boolean
) RETURNS       numeric
AS $$
BEGIN
  RETURN AddMethod(pParent, pClass, pState, pAction, pCode, pLabel, pSequence, pVisible);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.update_method -----------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Обновляет метод (операцию).
 * @param {numeric} pId - Идентификатор метода
 * @param {numeric} pParent - Идентификатор родителя (для создания вложенных методов, для построения меню)
 * @param {numeric} pClass - Идентификатор класса: api.class
 * @param {numeric} pState - Идентификатор состояния: api.state
 * @param {numeric} pAction - Идентификатор действия: api.action
 * @param {varchar} pCode - Код
 * @param {text} pLabel - Наименование
 * @param {integer} pSequence - Очередность
 * @param {boolean} pVisible - Видимый: Да/Нет
 * @return {record}
 */
CREATE OR REPLACE FUNCTION api.update_method (
  pId           numeric,
  pParent       numeric DEFAULT null,
  pClass        numeric DEFAULT null,
  pState        numeric DEFAULT null,
  pAction       numeric DEFAULT null,
  pCode         varchar DEFAULT null,
  pLabel        text DEFAULT null,
  pSequence     integer DEFAULT null,
  pVisible      boolean DEFAULT null
) RETURNS       void
AS $$
BEGIN
  PERFORM EditMethod(pId, pParent, pClass, pState, pAction, pCode, pLabel, pSequence, pVisible);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.delete_method -----------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Удаляет метод (операцию).
 * @param {numeric} pId - Идентификатор метода
 * @return {void}
 */
CREATE OR REPLACE FUNCTION api.delete_method (
  pId       numeric
) RETURNS   void
AS $$
BEGIN
  PERFORM DeleteMethod(pId);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.get_method --------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает методы объекта.
 * @param {numeric} pClass - Идентификатор класса
 * @param {numeric} pState - Идентификатор состояния
 * @param {numeric} pAction - Идентификатор действия
 * @out param {numeric} id - Идентификатор метода
 * @out param {numeric} parent - Идентификатор метода родителя
 * @out param {numeric} action - Идентификатор действия
 * @out param {varchar} actioncode - Код действия
 * @out param {varchar} code - Код метода
 * @out param {text} label - Описание метода
 * @out param {boolean} visible - Скрытый метод: Да/Нет
 * @return {record}
 */
CREATE OR REPLACE FUNCTION api.get_method (
  pClass          numeric,
  pState          numeric DEFAULT null,
  pAction         numeric DEFAULT null
) RETURNS TABLE (
  id          numeric,
  parent      numeric,
  action      numeric,
  actioncode  varchar,
  code        varchar,
  label       text,
  visible     boolean
)
AS $$
  SELECT m.id, m.parent, m.action, m.actioncode, m.code, m.label, m.visible
    FROM api.method m
   WHERE m.class = pClass
     AND m.state = coalesce(pState, m.state)
     AND m.action = coalesce(pAction, m.action)
   ORDER BY m.sequence
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.get_methods_json --------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION api.get_methods_json (
  pClass        numeric,
  pState        numeric
) RETURNS        json
AS $$
DECLARE
  arResult        json[];
  r             record;
BEGIN
  FOR r IN SELECT * FROM api.get_method(pClass, pState)
  LOOP
    arResult := array_append(arResult, row_to_json(r));
  END LOOP;

  RETURN array_to_json(arResult);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.get_methods_jsonb -------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION api.get_methods_jsonb (
  pClass        numeric,
  pState        numeric
) RETURNS        jsonb
AS $$
BEGIN
  RETURN api.get_methods_json(pClass, pState);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- TRANSITION ------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW api.transition
AS
  SELECT * FROM Transition;

GRANT SELECT ON api.transition TO administrator;

--------------------------------------------------------------------------------
-- api.add_transition ----------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Создаёт переход в новое состояние.
 * @param {numeric} pState - Идентификатор состояния
 * @param {numeric} pMethod - Идентификатор метода (операции)
 * @param {varchar} pNewState - Идентификатор нового состояния
 * @out param {numeric} id - Идентификатор перехода
 * @out param {boolean} result - Результат
 * @out param {text} message - Текст ошибки
 * @return {record}
 */
CREATE OR REPLACE FUNCTION api.add_transition (
  pState            numeric,
  pMethod            numeric,
  pNewState            numeric
) RETURNS             numeric
AS $$
BEGIN
  RETURN AddTransition(pState, pMethod, pNewState);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.update_transition -------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Обновляет переход в новое состояние.
 * @param {numeric} pId - Идентификатор перехода
 * @param {numeric} pState - Идентификатор состояния
 * @param {numeric} pMethod - Идентификатор метода (операции)
 * @param {varchar} pNewState - Идентификатор нового состояния
 * @return {void}
 */
CREATE OR REPLACE FUNCTION api.update_transition (
  pId                    numeric,
  pState            numeric DEFAULT null,
  pMethod            numeric DEFAULT null,
  pNewState            numeric DEFAULT null
) RETURNS             void
AS $$
BEGIN
  PERFORM EditTransition(pId, pState, pMethod, pNewState);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.delete_transition -------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Удаляет переход в новое состояние.
 * @param {numeric} pId - Идентификатор перехода
 * @return {numeric}
 */
CREATE OR REPLACE FUNCTION api.delete_transition (
  pId       numeric
) RETURNS   void
AS $$
BEGIN
  PERFORM DeleteTransition(pId);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.get_transition ----------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает переход.
 * @return {record} - Запись
 */
CREATE OR REPLACE FUNCTION api.get_transition (
  pId                numeric
) RETURNS        SETOF api.transition
AS $$
  SELECT * FROM api.transition WHERE id = pId
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- EVENT -----------------------------------------------------------------------
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW api.event_type
AS
  SELECT * FROM EventType;

GRANT SELECT ON api.event_type TO administrator;

--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW api.event
AS
  SELECT * FROM Event;

GRANT SELECT ON api.event TO administrator;

--------------------------------------------------------------------------------
-- api.get_event_type ----------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает тип события.
 * @return {record} - Запись
 */
CREATE OR REPLACE FUNCTION api.get_event_type (
  pId                numeric
) RETURNS        SETOF api.event_type
AS $$
  SELECT * FROM api.event_type WHERE id = pId;
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.add_event ---------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Создаёт событие.
 * @param {numeric} pClass - Идентификатор класса
 * @param {numeric} pType - Идентификатор типа
 * @param {numeric} pAction - Идентификатор действия
 * @param {text} pLabel - Наименование
 * @param {text} pText - PL/pgSQL Код
 * @param {integer} pSequence - Очередность
 * @param {boolean} pEnabled - Включен: Да/Нет
 * @return {numeric}
 */
CREATE OR REPLACE FUNCTION api.add_event (
  pClass            numeric,
  pType                    numeric,
  pAction            numeric,
  pLabel            text,
  pText                    text,
  pSequence            integer,
  pEnabled            boolean
) RETURNS             numeric
AS $$
BEGIN
  RETURN AddEvent(pClass, pType, pAction, pLabel, pText, pSequence, pEnabled);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.update_event ------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Обновляет событие.
 * @param {numeric} pId - Идентификатор события
 * @param {numeric} pClass - Идентификатор класса
 * @param {numeric} pType - Идентификатор типа
 * @param {numeric} pAction - Идентификатор действия
 * @param {text} pLabel - Наименование
 * @param {text} pText - PL/pgSQL Код
 * @param {integer} pSequence - Очередность
 * @param {boolean} pEnabled - Включен: Да/Нет
 * @return {void}
 */
CREATE OR REPLACE FUNCTION api.update_event (
  pId                    numeric,
  pClass            numeric DEFAULT null,
  pType                    numeric DEFAULT null,
  pAction            numeric DEFAULT null,
  pLabel            text DEFAULT null,
  pText                    text DEFAULT null,
  pSequence            integer DEFAULT null,
  pEnabled            boolean DEFAULT null
) RETURNS             void
AS $$
BEGIN
  PERFORM EditEvent(pId, pClass, pType, pAction, pLabel, pText, pSequence, pEnabled);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.delete_event ------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Удаляет событие.
 * @param {numeric} pId - Идентификатор события
 * @return {void}
 */
CREATE OR REPLACE FUNCTION api.delete_state (
  pId       numeric
) RETURNS   void
AS $$
BEGIN
  PERFORM DeleteEvent(pId);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.get_event ---------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Возвращает событыие.
 * @return {record} - Запись
 */
CREATE OR REPLACE FUNCTION api.get_event (
  pId            numeric
) RETURNS        SETOF api.event
AS $$
  SELECT * FROM api.event WHERE id = pId
$$ LANGUAGE SQL
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.run_action --------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Выполняет действие над объектом.
 * @param {numeric} pObject - Идентификатор объекта
 * @param {numeric} pAction - Идентификатор действия
 * @param {jsonb} pForm - Форма в формате JSON
 * @return {jsonb}
 */
CREATE OR REPLACE FUNCTION api.run_action (
  pObject            numeric,
  pAction            numeric,
  pForm              jsonb DEFAULT null
) RETURNS            jsonb
AS $$
DECLARE
  nId                numeric;
  nMethod            numeric;
BEGIN
  SELECT o.id INTO nId FROM db.object o WHERE o.id = pObject;

  IF NOT FOUND THEN
    PERFORM ObjectNotFound('объект', 'id', pObject);
  END IF;

  IF pAction IS NULL THEN
    PERFORM ActionIsEmpty();
  END IF;

  nMethod := GetObjectMethod(pObject, pAction);

  IF nMethod IS NULL THEN
    PERFORM MethodActionNotFound(pObject, pAction);
  END IF;

  PERFORM ExecuteObjectAction(pObject, pAction, pForm);

  RETURN GetMethodResult(pObject, nMethod);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.run_action --------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Выполняет действие над объектом по коду.
 * @param {numeric} pObject - Идентификатор объекта
 * @param {varchar} pCode - Код действия
 * @param {jsonb} pForm - Форма в формате JSON
 * @out param {numeric} id - Идентификатор объекта
 * @out param {boolean} result - Результат
 * @out param {text} message - Текст ошибки
 * @return {jsonb}
 */
CREATE OR REPLACE FUNCTION api.run_action (
  pObject       numeric,
  pCode         varchar,
  pForm         jsonb DEFAULT null
) RETURNS       jsonb
AS $$
DECLARE
  arCodes       text[];
  r             record;
BEGIN
  FOR r IN SELECT code FROM db.action
  LOOP
    arCodes := array_append(arCodes, r.code);
  END LOOP;

  IF array_position(arCodes, pCode::text) IS NULL THEN
    PERFORM IncorrectCode(pCode, arCodes);
  END IF;

  RETURN api.run_action(pObject, GetAction(pCode), pForm);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;

--------------------------------------------------------------------------------
-- api.run_method --------------------------------------------------------------
--------------------------------------------------------------------------------
/**
 * Выполняет метод.
 * @param {numeric} pObject - Идентификатор объекта
 * @param {numeric} pMethod - Идентификатор метода
 * @param {text} pCode - Код метода (Игнорируется если указан идентификатор метода)
 * @param {jsonb} pForm - Форма в формате JSON
 * @return {jsonb}
 */
CREATE OR REPLACE FUNCTION api.run_method (
  pObject       numeric,
  pMethod       numeric,
  pCode         text,
  pForm         jsonb DEFAULT null
) RETURNS       jsonb
AS $$
DECLARE
  nId           numeric;
  nClass        numeric;
  nMethod       numeric;
BEGIN
  SELECT o.id INTO nId FROM db.object o WHERE o.id = pObject;

  IF NOT FOUND THEN
    PERFORM ObjectNotFound('объект', 'id', pObject);
  END IF;

  IF pMethod IS NULL THEN

    IF pCode IS NULL THEN
      PERFORM MethodIsEmpty();
    END IF;

    nClass := GetObjectClass(pObject);

    SELECT m.id INTO nMethod FROM db.method m WHERE m.class = nClass AND m.code = pCode;

    IF NOT FOUND THEN
      PERFORM MethodByCodeNotFound(pObject, pCode);
    END IF;
  ELSE
    SELECT m.id INTO nMethod FROM method m WHERE m.id = pMethod;

    IF NOT FOUND THEN
      PERFORM MethodNotFound(pObject, pMethod);
    END IF;
  END IF;

  RETURN ExecuteMethod(pObject, nMethod, pForm);
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = kernel, pg_temp;
