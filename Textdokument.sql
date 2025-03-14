-- @__endAttributesRole_0={ '42', '79', '110' } (DbType = Object)
SELECT
    p.id,
    p.created,
    p.deactivated,
    p.deleted,
    p.deleted_on,
    p.description,
    p.hidden,
    p.importdate,
    p.lastmodificationdate,
    p.lastmodifier,
    p.part_of,
    p.person,
    p.personroletype,
    p.similar_to,
    p.version,
    (
        SELECT
            max(
                (
                    SELECT
                        MAX(date)
                    FROM
                        (
                            SELECT
                                TO_DATE(
                                    UNNEST(STRING_TO_ARRAY(p15.value, ',')),
                                    'DD.MM.YYYY'
                                ) AS date,
                                '1' AS key
                        ) foo
                    WHERE
                        p15.value NOT LIKE '∞'
                    GROUP BY
                        key
                ) + CASE
                    WHEN p15.attribute = 110 THEN 1
                    ELSE 0
                END
            )
        FROM
            personroledata AS p15
        WHERE
            p.id = p15.personrole
            AND p15.attribute::BIGINT IN (42, 79, 110)
            AND (
                p15.value NOT LIKE '%∞%'
                OR p15.value IS NULL
            )
            AND (
                SELECT
                    MAX(date)
                FROM
                    (
                        SELECT
                            TO_DATE(
                                UNNEST(STRING_TO_ARRAY(p15.value, ',')),
                                'DD.MM.YYYY'
                            ) AS date,
                            '1' AS key
                    ) foo
                WHERE
                    p15.value NOT LIKE '∞'
                GROUP BY
                    key
            ) IS NOT NULL
    ) AS "RoleEndDate",
    (
        SELECT
            c39.waitingtime
        FROM
            configuration_roletype_waiting_time AS c39
        WHERE
            c39.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
        LIMIT
            1
    ) AS "Waitingtime",
    (
        SELECT
            c40.notification_time
        FROM
            configuration_roletype_waiting_time AS c40
        WHERE
            c40.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
        LIMIT
            1
    ) AS "NotificationTime",
    (
        SELECT
            c41.notification_text
        FROM
            configuration_roletype_waiting_time AS c41
        WHERE
            c41.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
        LIMIT
            1
    ) AS "NotificationText",
    (
        SELECT
            c42.import_threshhold_check
        FROM
            configuration_roletype_waiting_time AS c42
        WHERE
            c42.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
        LIMIT
            1
    ) AS "ImportThreshholdCheck",
    (
        SELECT
            c43.import_deletion_threshhold
        FROM
            configuration_roletype_waiting_time AS c43
        WHERE
            c43.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
        LIMIT
            1
    ) AS "ImportDeletionThreshhold",
    (
        SELECT
            c44.import_deletion_faild_requests
        FROM
            configuration_roletype_waiting_time AS c44
        WHERE
            c44.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
        LIMIT
            1
    ) AS "ImportDeletionFaildRequests",
    (
        SELECT
            c45.import_deletion_faild_requests_threshhold
        FROM
            configuration_roletype_waiting_time AS c45
        WHERE
            c45.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
        LIMIT
            1
    ) AS "ImportDeletionFaildRequestsThreshhold",
    (
        SELECT
            c46.safe_deletion_threshold
        FROM
            configuration_roletype_waiting_time AS c46
        WHERE
            c46.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
        LIMIT
            1
    ) AS "SafeDeletionThreshold",
    CASE
        WHEN (
            SELECT
                c47.import_threshhold_check IS NOT NULL
            FROM
                configuration_roletype_waiting_time AS c47
            WHERE
                c47.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
            LIMIT
                1
        )
        AND NOT (
            (
                SELECT
                    c48.import_deletion_faild_requests_threshhold IS NOT NULL
                FROM
                    configuration_roletype_waiting_time AS c48
                WHERE
                    c48.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                LIMIT
                    1
            )
        )
        AND CAST(
            (
                p.importdate + (
                    SELECT
                        c49.import_threshhold_check
                    FROM
                        configuration_roletype_waiting_time AS c49
                    WHERE
                        c49.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                    LIMIT
                        1
                )
            ) at TIME ZONE 'UTC' AS date
        ) < now()::TIMESTAMP::date THEN CAST(
            (
                p.importdate + (
                    SELECT
                        c50.import_threshhold_check
                    FROM
                        configuration_roletype_waiting_time AS c50
                    WHERE
                        c50.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                    LIMIT
                        1
                )
            ) at TIME ZONE 'UTC' AS date
        )
    END AS "ImportThresholadDate",
    CASE
        WHEN (
            SELECT
                c51.import_threshhold_check IS NOT NULL
            FROM
                configuration_roletype_waiting_time AS c51
            WHERE
                c51.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
            LIMIT
                1
        )
        AND (
            SELECT
                c52.import_deletion_faild_requests_threshhold IS NOT NULL
            FROM
                configuration_roletype_waiting_time AS c52
            WHERE
                c52.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
            LIMIT
                1
        )
        AND CAST(
            (
                p.importdate + (
                    SELECT
                        c53.import_threshhold_check
                    FROM
                        configuration_roletype_waiting_time AS c53
                    WHERE
                        c53.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                    LIMIT
                        1
                )
            ) at TIME ZONE 'UTC' AS date
        ) < now()::TIMESTAMP::date
        AND (
            SELECT
                count(*)::INT
            FROM
                (
                    SELECT DISTINCT
                        p16.id,
                        p16.attribute,
                        p16.created,
                        p16.importdate,
                        p16.lastmodificationdate,
                        p16.lastmodifier,
                        p16.personrole,
                        p16.value,
                        p16.version
                    FROM
                        personroledata AS p16
                    WHERE
                        p.id = p16.personrole
                        AND p16.attribute = 145
                        AND (
                            SELECT
                                MAX(date)
                            FROM
                                (
                                    SELECT
                                        TO_DATE(
                                            UNNEST(STRING_TO_ARRAY(p16.value, ',')),
                                            'DD.MM.YYYY'
                                        ) AS date,
                                        '1' AS key
                                ) foo
                            WHERE
                                p16.value NOT LIKE '∞'
                            GROUP BY
                                key
                        ) IS NOT NULL
                        AND p.importdate IS NOT NULL
                        AND (
                            SELECT
                                MAX(date)
                            FROM
                                (
                                    SELECT
                                        TO_DATE(
                                            UNNEST(STRING_TO_ARRAY(p16.value, ',')),
                                            'DD.MM.YYYY'
                                        ) AS date,
                                        '1' AS key
                                ) foo
                            WHERE
                                p16.value NOT LIKE '∞'
                            GROUP BY
                                key
                        ) > CAST(p.importdate at TIME ZONE 'UTC' AS date)
                ) AS p17
        ) > (
            SELECT
                c54.import_deletion_faild_requests_threshhold
            FROM
                configuration_roletype_waiting_time AS c54
            WHERE
                c54.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
            LIMIT
                1
        ) THEN CAST(
            (
                p.importdate + (
                    SELECT
                        c55.import_threshhold_check
                    FROM
                        configuration_roletype_waiting_time AS c55
                    WHERE
                        c55.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                    LIMIT
                        1
                )
            ) at TIME ZONE 'UTC' AS date
        )
    END AS "ImportThresholdFaildRequests",
    CASE
        WHEN p.deleted = 2
        OR (
            (
                NOT (
                    (
                        SELECT
                            c56.import_threshhold_check IS NOT NULL
                        FROM
                            configuration_roletype_waiting_time AS c56
                        WHERE
                            c56.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                        LIMIT
                            1
                    )
                )
                OR (
                    SELECT
                        c57.import_deletion_faild_requests_threshhold IS NOT NULL
                    FROM
                        configuration_roletype_waiting_time AS c57
                    WHERE
                        c57.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                    LIMIT
                        1
                )
                OR CASE
                    WHEN CAST(
                        (
                            p.importdate + (
                                SELECT
                                    c58.import_threshhold_check
                                FROM
                                    configuration_roletype_waiting_time AS c58
                                WHERE
                                    c58.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                LIMIT
                                    1
                            )
                        ) at TIME ZONE 'UTC' AS date
                    ) < now()::TIMESTAMP::date THEN FALSE
                    ELSE TRUE
                END
                OR p.importdate IS NULL
                OR (
                    SELECT
                        c59.import_threshhold_check
                    FROM
                        configuration_roletype_waiting_time AS c59
                    WHERE
                        c59.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                    LIMIT
                        1
                ) IS NULL
            )
            AND (
                NOT (
                    (
                        SELECT
                            c60.import_threshhold_check IS NOT NULL
                        FROM
                            configuration_roletype_waiting_time AS c60
                        WHERE
                            c60.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                        LIMIT
                            1
                    )
                )
                OR NOT (
                    (
                        SELECT
                            c61.import_deletion_faild_requests_threshhold IS NOT NULL
                        FROM
                            configuration_roletype_waiting_time AS c61
                        WHERE
                            c61.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                        LIMIT
                            1
                    )
                )
                OR CASE
                    WHEN CAST(
                        (
                            p.importdate + (
                                SELECT
                                    c62.import_threshhold_check
                                FROM
                                    configuration_roletype_waiting_time AS c62
                                WHERE
                                    c62.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                LIMIT
                                    1
                            )
                        ) at TIME ZONE 'UTC' AS date
                    ) < now()::TIMESTAMP::date THEN FALSE
                    ELSE TRUE
                END
                OR CASE
                    WHEN (
                        SELECT
                            count(*)::INT
                        FROM
                            (
                                SELECT DISTINCT
                                    p18.id,
                                    p18.attribute,
                                    p18.created,
                                    p18.importdate,
                                    p18.lastmodificationdate,
                                    p18.lastmodifier,
                                    p18.personrole,
                                    p18.value,
                                    p18.version
                                FROM
                                    personroledata AS p18
                                WHERE
                                    p.id = p18.personrole
                                    AND p18.attribute = 145
                                    AND (
                                        SELECT
                                            MAX(date)
                                        FROM
                                            (
                                                SELECT
                                                    TO_DATE(
                                                        UNNEST(STRING_TO_ARRAY(p18.value, ',')),
                                                        'DD.MM.YYYY'
                                                    ) AS date,
                                                    '1' AS key
                                            ) foo
                                        WHERE
                                            p18.value NOT LIKE '∞'
                                        GROUP BY
                                            key
                                    ) IS NOT NULL
                                    AND p.importdate IS NOT NULL
                                    AND (
                                        SELECT
                                            MAX(date)
                                        FROM
                                            (
                                                SELECT
                                                    TO_DATE(
                                                        UNNEST(STRING_TO_ARRAY(p18.value, ',')),
                                                        'DD.MM.YYYY'
                                                    ) AS date,
                                                    '1' AS key
                                            ) foo
                                        WHERE
                                            p18.value NOT LIKE '∞'
                                        GROUP BY
                                            key
                                    ) > CAST(p.importdate at TIME ZONE 'UTC' AS date)
                            ) AS p19
                    ) > (
                        SELECT
                            c63.import_deletion_faild_requests_threshhold
                        FROM
                            configuration_roletype_waiting_time AS c63
                        WHERE
                            c63.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                        LIMIT
                            1
                    ) THEN FALSE
                    ELSE TRUE
                END
                OR p.importdate IS NULL
                OR (
                    SELECT
                        c64.import_threshhold_check
                    FROM
                        configuration_roletype_waiting_time AS c64
                    WHERE
                        c64.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                    LIMIT
                        1
                ) IS NULL
            )
            AND (
                SELECT
                    max(
                        (
                            SELECT
                                MAX(date)
                            FROM
                                (
                                    SELECT
                                        TO_DATE(
                                            UNNEST(STRING_TO_ARRAY(p20.value, ',')),
                                            'DD.MM.YYYY'
                                        ) AS date,
                                        '1' AS key
                                ) foo
                            WHERE
                                p20.value NOT LIKE '∞'
                            GROUP BY
                                key
                        ) + CASE
                            WHEN p20.attribute = 110 THEN 1
                            ELSE 0
                        END
                    )
                FROM
                    personroledata AS p20
                WHERE
                    p.id = p20.personrole
                    AND p20.attribute::BIGINT IN (42, 79, 110)
                    AND (
                        p20.value NOT LIKE '%∞%'
                        OR p20.value IS NULL
                    )
                    AND (
                        SELECT
                            MAX(date)
                        FROM
                            (
                                SELECT
                                    TO_DATE(
                                        UNNEST(STRING_TO_ARRAY(p20.value, ',')),
                                        'DD.MM.YYYY'
                                    ) AS date,
                                    '1' AS key
                            ) foo
                        WHERE
                            p20.value NOT LIKE '∞'
                        GROUP BY
                            key
                    ) IS NOT NULL
            ) IS NULL
            AND p.deleted IN (1, 10)
        ) THEN CAST(p.deleted_on at TIME ZONE 'UTC' AS date)
        ELSE (
            SELECT
                min(v1."Value")
            FROM
                (
                    VALUES
                        (
                            CAST(
                                CASE
                                    WHEN (
                                        SELECT
                                            c65.import_threshhold_check IS NOT NULL
                                        FROM
                                            configuration_roletype_waiting_time AS c65
                                        WHERE
                                            c65.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                        LIMIT
                                            1
                                    )
                                    AND NOT (
                                        (
                                            SELECT
                                                c66.import_deletion_faild_requests_threshhold IS NOT NULL
                                            FROM
                                                configuration_roletype_waiting_time AS c66
                                            WHERE
                                                c66.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                            LIMIT
                                                1
                                        )
                                    )
                                    AND CAST(
                                        (
                                            p.importdate + (
                                                SELECT
                                                    c67.import_threshhold_check
                                                FROM
                                                    configuration_roletype_waiting_time AS c67
                                                WHERE
                                                    c67.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                                LIMIT
                                                    1
                                            )
                                        ) at TIME ZONE 'UTC' AS date
                                    ) < now()::TIMESTAMP::date THEN CAST(
                                        (
                                            p.importdate + (
                                                SELECT
                                                    c68.import_threshhold_check
                                                FROM
                                                    configuration_roletype_waiting_time AS c68
                                                WHERE
                                                    c68.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                                LIMIT
                                                    1
                                            )
                                        ) at TIME ZONE 'UTC' AS date
                                    )
                                END AS date
                            )
                        ),
                        (
                            CASE
                                WHEN (
                                    SELECT
                                        c69.import_threshhold_check IS NOT NULL
                                    FROM
                                        configuration_roletype_waiting_time AS c69
                                    WHERE
                                        c69.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                    LIMIT
                                        1
                                )
                                AND (
                                    SELECT
                                        c70.import_deletion_faild_requests_threshhold IS NOT NULL
                                    FROM
                                        configuration_roletype_waiting_time AS c70
                                    WHERE
                                        c70.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                    LIMIT
                                        1
                                )
                                AND CAST(
                                    (
                                        p.importdate + (
                                            SELECT
                                                c71.import_threshhold_check
                                            FROM
                                                configuration_roletype_waiting_time AS c71
                                            WHERE
                                                c71.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                            LIMIT
                                                1
                                        )
                                    ) at TIME ZONE 'UTC' AS date
                                ) < now()::TIMESTAMP::date
                                AND (
                                    SELECT
                                        count(*)::INT
                                    FROM
                                        (
                                            SELECT DISTINCT
                                                p21.id,
                                                p21.attribute,
                                                p21.created,
                                                p21.importdate,
                                                p21.lastmodificationdate,
                                                p21.lastmodifier,
                                                p21.personrole,
                                                p21.value,
                                                p21.version
                                            FROM
                                                personroledata AS p21
                                            WHERE
                                                p.id = p21.personrole
                                                AND p21.attribute = 145
                                                AND (
                                                    SELECT
                                                        MAX(date)
                                                    FROM
                                                        (
                                                            SELECT
                                                                TO_DATE(
                                                                    UNNEST(STRING_TO_ARRAY(p21.value, ',')),
                                                                    'DD.MM.YYYY'
                                                                ) AS date,
                                                                '1' AS key
                                                        ) foo
                                                    WHERE
                                                        p21.value NOT LIKE '∞'
                                                    GROUP BY
                                                        key
                                                ) IS NOT NULL
                                                AND p.importdate IS NOT NULL
                                                AND (
                                                    SELECT
                                                        MAX(date)
                                                    FROM
                                                        (
                                                            SELECT
                                                                TO_DATE(
                                                                    UNNEST(STRING_TO_ARRAY(p21.value, ',')),
                                                                    'DD.MM.YYYY'
                                                                ) AS date,
                                                                '1' AS key
                                                        ) foo
                                                    WHERE
                                                        p21.value NOT LIKE '∞'
                                                    GROUP BY
                                                        key
                                                ) > CAST(p.importdate at TIME ZONE 'UTC' AS date)
                                        ) AS p22
                                ) > (
                                    SELECT
                                        c72.import_deletion_faild_requests_threshhold
                                    FROM
                                        configuration_roletype_waiting_time AS c72
                                    WHERE
                                        c72.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                    LIMIT
                                        1
                                ) THEN CAST(
                                    (
                                        p.importdate + (
                                            SELECT
                                                c73.import_threshhold_check
                                            FROM
                                                configuration_roletype_waiting_time AS c73
                                            WHERE
                                                c73.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                            LIMIT
                                                1
                                        )
                                    ) at TIME ZONE 'UTC' AS date
                                )
                            END
                        ),
                        (
                            (
                                SELECT
                                    max(
                                        (
                                            SELECT
                                                MAX(date)
                                            FROM
                                                (
                                                    SELECT
                                                        TO_DATE(
                                                            UNNEST(STRING_TO_ARRAY(p23.value, ',')),
                                                            'DD.MM.YYYY'
                                                        ) AS date,
                                                        '1' AS key
                                                ) foo
                                            WHERE
                                                p23.value NOT LIKE '∞'
                                            GROUP BY
                                                key
                                        ) + CASE
                                            WHEN p23.attribute = 110 THEN 1
                                            ELSE 0
                                        END
                                    )
                                FROM
                                    personroledata AS p23
                                WHERE
                                    p.id = p23.personrole
                                    AND p23.attribute::BIGINT in ( 42, 79, 110 )
                                    AND (
                                        p23.value NOT LIKE '%∞%'
                                        OR p23.value IS NULL
                                    )
                                    AND (
                                        SELECT
                                            MAX(date)
                                        FROM
                                            (
                                                SELECT
                                                    TO_DATE(
                                                        UNNEST(STRING_TO_ARRAY(p23.value, ',')),
                                                        'DD.MM.YYYY'
                                                    ) AS date,
                                                    '1' AS key
                                            ) foo
                                        WHERE
                                            p23.value NOT LIKE '∞'
                                        GROUP BY
                                            key
                                    ) IS NOT NULL
                            )
                        )
                ) AS v1 ("Value")
            WHERE
                v1."Value" IS NOT NULL
        )
    END AS "DueDate"
FROM
    personrole AS p
WHERE
    EXISTS (
        SELECT
            1
        FROM
            configuration_roletype_waiting_time AS c
        WHERE
            c.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            personroledata AS p0
        WHERE
            p.id = p0.personrole
            AND p0.attribute = 135
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            personrole AS p1
        WHERE
            EXISTS (
                SELECT
                    1
                FROM
                    configuration_roletype_waiting_time AS c0
                WHERE
                    c0.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
            )
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    personroledata AS p2
                WHERE
                    p1.id = p2.personrole
                    AND p2.attribute = 135
            )
            AND p.person = p1.person
            AND p.id <> p1.id
            AND p1.deleted <> 1
            AND (
                (
                    SELECT
                        c1.notification_text
                    FROM
                        configuration_roletype_waiting_time AS c1
                    WHERE
                        c1.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                    LIMIT
                        1
                ) = (
                    SELECT
                        c2.notification_text
                    FROM
                        configuration_roletype_waiting_time AS c2
                    WHERE
                        c2.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                    LIMIT
                        1
                )
                OR (
                    (
                        SELECT
                            c1.notification_text
                        FROM
                            configuration_roletype_waiting_time AS c1
                        WHERE
                            c1.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                        LIMIT
                            1
                    ) IS NULL
                    AND (
                        SELECT
                            c2.notification_text
                        FROM
                            configuration_roletype_waiting_time AS c2
                        WHERE
                            c2.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                        LIMIT
                            1
                    ) IS NULL
                )
            )
            AND CASE
                WHEN p.deleted = 2
                OR (
                    (
                        NOT (
                            (
                                SELECT
                                    c3.import_threshhold_check IS NOT NULL
                                FROM
                                    configuration_roletype_waiting_time AS c3
                                WHERE
                                    c3.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                LIMIT
                                    1
                            )
                        )
                        OR (
                            SELECT
                                c4.import_deletion_faild_requests_threshhold IS NOT NULL
                            FROM
                                configuration_roletype_waiting_time AS c4
                            WHERE
                                c4.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                            LIMIT
                                1
                        )
                        OR CASE
                            WHEN CAST(
                                (
                                    p.importdate + (
                                        SELECT
                                            c5.import_threshhold_check
                                        FROM
                                            configuration_roletype_waiting_time AS c5
                                        WHERE
                                            c5.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                        LIMIT
                                            1
                                    )
                                ) at TIME ZONE 'UTC' AS date
                            ) < now()::TIMESTAMP::date THEN FALSE
                            ELSE TRUE
                        END
                        OR p.importdate IS NULL
                        OR (
                            SELECT
                                c6.import_threshhold_check
                            FROM
                                configuration_roletype_waiting_time AS c6
                            WHERE
                                c6.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                            LIMIT
                                1
                        ) IS NULL
                    )
                    AND (
                        NOT (
                            (
                                SELECT
                                    c7.import_threshhold_check IS NOT NULL
                                FROM
                                    configuration_roletype_waiting_time AS c7
                                WHERE
                                    c7.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                LIMIT
                                    1
                            )
                        )
                        OR NOT (
                            (
                                SELECT
                                    c8.import_deletion_faild_requests_threshhold IS NOT NULL
                                FROM
                                    configuration_roletype_waiting_time AS c8
                                WHERE
                                    c8.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                LIMIT
                                    1
                            )
                        )
                        OR CASE
                            WHEN CAST(
                                (
                                    p.importdate + (
                                        SELECT
                                            c9.import_threshhold_check
                                        FROM
                                            configuration_roletype_waiting_time AS c9
                                        WHERE
                                            c9.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                        LIMIT
                                            1
                                    )
                                ) at TIME ZONE 'UTC' AS date
                            ) < now()::TIMESTAMP::date THEN FALSE
                            ELSE TRUE
                        END
                        OR CASE
                            WHEN (
                                SELECT
                                    count(*)::INT
                                FROM
                                    (
                                        SELECT DISTINCT
                                            p3.id,
                                            p3.attribute,
                                            p3.created,
                                            p3.importdate,
                                            p3.lastmodificationdate,
                                            p3.lastmodifier,
                                            p3.personrole,
                                            p3.value,
                                            p3.version
                                        FROM
                                            personroledata AS p3
                                        WHERE
                                            p.id = p3.personrole
                                            AND p3.attribute = 145
                                            AND (
                                                SELECT
                                                    MAX(date)
                                                FROM
                                                    (
                                                        SELECT
                                                            TO_DATE(
                                                                UNNEST(STRING_TO_ARRAY(p3.value, ',')),
                                                                'DD.MM.YYYY'
                                                            ) AS date,
                                                            '1' AS key
                                                    ) foo
                                                WHERE
                                                    p3.value NOT LIKE '∞'
                                                GROUP BY
                                                    key
                                            ) IS NOT NULL
                                            AND p.importdate IS NOT NULL
                                            AND (
                                                SELECT
                                                    MAX(date)
                                                FROM
                                                    (
                                                        SELECT
                                                            TO_DATE(
                                                                UNNEST(STRING_TO_ARRAY(p3.value, ',')),
                                                                'DD.MM.YYYY'
                                                            ) AS date,
                                                            '1' AS key
                                                    ) foo
                                                WHERE
                                                    p3.value NOT LIKE '∞'
                                                GROUP BY
                                                    key
                                            ) > CAST(p.importdate at TIME ZONE 'UTC' AS date)
                                    ) AS p4
                            ) > (
                                SELECT
                                    c10.import_deletion_faild_requests_threshhold
                                FROM
                                    configuration_roletype_waiting_time AS c10
                                WHERE
                                    c10.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                LIMIT
                                    1
                            ) THEN FALSE
                            ELSE TRUE
                        END
                        OR p.importdate IS NULL
                        OR (
                            SELECT
                                c11.import_threshhold_check
                            FROM
                                configuration_roletype_waiting_time AS c11
                            WHERE
                                c11.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                            LIMIT
                                1
                        ) IS NULL
                    )
                    AND (
                        SELECT
                            max(
                                (
                                    SELECT
                                        MAX(date)
                                    FROM
                                        (
                                            SELECT
                                                TO_DATE(
                                                    UNNEST(STRING_TO_ARRAY(p5.value, ',')),
                                                    'DD.MM.YYYY'
                                                ) AS date,
                                                '1' AS key
                                        ) foo
                                    WHERE
                                        p5.value NOT LIKE '∞'
                                    GROUP BY
                                        key
                                ) + CASE
                                    WHEN p5.attribute = 110 THEN 1
                                    ELSE 0
                                END
                            )
                        FROM
                            personroledata AS p5
                        WHERE
                            p.id = p5.personrole
                            AND p5.attribute::BIGINT in ( 42, 79, 110 )
                            AND (
                                p5.value NOT LIKE '%∞%'
                                OR p5.value IS NULL
                            )
                            AND (
                                SELECT
                                    MAX(date)
                                FROM
                                    (
                                        SELECT
                                            TO_DATE(
                                                UNNEST(STRING_TO_ARRAY(p5.value, ',')),
                                                'DD.MM.YYYY'
                                            ) AS date,
                                            '1' AS key
                                    ) foo
                                WHERE
                                    p5.value NOT LIKE '∞'
                                GROUP BY
                                    key
                            ) IS NOT NULL
                    ) IS NULL
                    AND p.deleted IN (1, 10)
                ) THEN CAST(p.deleted_on at TIME ZONE 'UTC' AS date)
                ELSE (
                    SELECT
                        min(v."Value")
                    FROM
                        (
                            VALUES
                                (
                                    CAST(
                                        CASE
                                            WHEN (
                                                SELECT
                                                    c12.import_threshhold_check IS NOT NULL
                                                FROM
                                                    configuration_roletype_waiting_time AS c12
                                                WHERE
                                                    c12.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                                LIMIT
                                                    1
                                            )
                                            AND NOT (
                                                (
                                                    SELECT
                                                        c13.import_deletion_faild_requests_threshhold IS NOT NULL
                                                    FROM
                                                        configuration_roletype_waiting_time AS c13
                                                    WHERE
                                                        c13.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                                    LIMIT
                                                        1
                                                )
                                            )
                                            AND CAST(
                                                (
                                                    p.importdate + (
                                                        SELECT
                                                            c14.import_threshhold_check
                                                        FROM
                                                            configuration_roletype_waiting_time AS c14
                                                        WHERE
                                                            c14.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                                        LIMIT
                                                            1
                                                    )
                                                ) at TIME ZONE 'UTC' AS date
                                            ) < now()::TIMESTAMP::date THEN CAST(
                                                (
                                                    p.importdate + (
                                                        SELECT
                                                            c15.import_threshhold_check
                                                        FROM
                                                            configuration_roletype_waiting_time AS c15
                                                        WHERE
                                                            c15.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                                        LIMIT
                                                            1
                                                    )
                                                ) at TIME ZONE 'UTC' AS date
                                            )
                                        END AS date
                                    )
                                ),
                                (
                                    CASE
                                        WHEN (
                                            SELECT
                                                c16.import_threshhold_check IS NOT NULL
                                            FROM
                                                configuration_roletype_waiting_time AS c16
                                            WHERE
                                                c16.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                            LIMIT
                                                1
                                        )
                                        AND (
                                            SELECT
                                                c17.import_deletion_faild_requests_threshhold IS NOT NULL
                                            FROM
                                                configuration_roletype_waiting_time AS c17
                                            WHERE
                                                c17.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                            LIMIT
                                                1
                                        )
                                        AND CAST(
                                            (
                                                p.importdate + (
                                                    SELECT
                                                        c18.import_threshhold_check
                                                    FROM
                                                        configuration_roletype_waiting_time AS c18
                                                    WHERE
                                                        c18.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                                    LIMIT
                                                        1
                                                )
                                            ) at TIME ZONE 'UTC' AS date
                                        ) < now()::TIMESTAMP::date
                                        AND (
                                            SELECT
                                                count(*)::INT
                                            FROM
                                                (
                                                    SELECT DISTINCT
                                                        p6.id,
                                                        p6.attribute,
                                                        p6.created,
                                                        p6.importdate,
                                                        p6.lastmodificationdate,
                                                        p6.lastmodifier,
                                                        p6.personrole,
                                                        p6.value,
                                                        p6.version
                                                    FROM
                                                        personroledata AS p6
                                                    WHERE
                                                        p.id = p6.personrole
                                                        AND p6.attribute = 145
                                                        AND (
                                                            SELECT
                                                                MAX(date)
                                                            FROM
                                                                (
                                                                    SELECT
                                                                        TO_DATE(
                                                                            UNNEST(STRING_TO_ARRAY(p6.value, ',')),
                                                                            'DD.MM.YYYY'
                                                                        ) AS date,
                                                                        '1' AS key
                                                                ) foo
                                                            WHERE
                                                                p6.value NOT LIKE '∞'
                                                            GROUP BY
                                                                key
                                                        ) IS NOT NULL
                                                        AND p.importdate IS NOT NULL
                                                        AND (
                                                            SELECT
                                                                MAX(date)
                                                            FROM
                                                                (
                                                                    SELECT
                                                                        TO_DATE(
                                                                            UNNEST(STRING_TO_ARRAY(p6.value, ',')),
                                                                            'DD.MM.YYYY'
                                                                        ) AS date,
                                                                        '1' AS key
                                                                ) foo
                                                            WHERE
                                                                p6.value NOT LIKE '∞'
                                                            GROUP BY
                                                                key
                                                        ) > CAST(p.importdate at TIME ZONE 'UTC' AS date)
                                                ) AS p7
                                        ) > (
                                            SELECT
                                                c19.import_deletion_faild_requests_threshhold
                                            FROM
                                                configuration_roletype_waiting_time AS c19
                                            WHERE
                                                c19.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                            LIMIT
                                                1
                                        ) THEN CAST(
                                            (
                                                p.importdate + (
                                                    SELECT
                                                        c20.import_threshhold_check
                                                    FROM
                                                        configuration_roletype_waiting_time AS c20
                                                    WHERE
                                                        c20.type_id @> ARRAY[p.personroletype::INT]::INTEGER[]
                                                    LIMIT
                                                        1
                                                )
                                            ) at TIME ZONE 'UTC' AS date
                                        )
                                    END
                                ),
                                (
                                    (
                                        SELECT
                                            max(
                                                (
                                                    SELECT
                                                        MAX(date)
                                                    FROM
                                                        (
                                                            SELECT
                                                                TO_DATE(
                                                                    UNNEST(STRING_TO_ARRAY(p8.value, ',')),
                                                                    'DD.MM.YYYY'
                                                                ) AS date,
                                                                '1' AS key
                                                        ) foo
                                                    WHERE
                                                        p8.value NOT LIKE '∞'
                                                    GROUP BY
                                                        key
                                                ) + CASE
                                                    WHEN p8.attribute = 110 THEN 1
                                                    ELSE 0
                                                END
                                            )
                                        FROM
                                            personroledata AS p8
                                        WHERE
                                            p.id = p8.personrole
                                            AND p8.attribute::BIGINT in ( 42, 79, 110 )
                                            AND (
                                                p8.value NOT LIKE '%∞%'
                                                OR p8.value IS NULL
                                            )
                                            AND (
                                                SELECT
                                                    MAX(date)
                                                FROM
                                                    (
                                                        SELECT
                                                            TO_DATE(
                                                                UNNEST(STRING_TO_ARRAY(p8.value, ',')),
                                                                'DD.MM.YYYY'
                                                            ) AS date,
                                                            '1' AS key
                                                    ) foo
                                                WHERE
                                                    p8.value NOT LIKE '∞'
                                                GROUP BY
                                                    key
                                            ) IS NOT NULL
                                    )
                                )
                        ) AS v ("Value")
                    WHERE
                        v."Value" IS NOT NULL
                )
            END < CASE
                WHEN p1.deleted = 2
                OR (
                    (
                        NOT (
                            (
                                SELECT
                                    c21.import_threshhold_check IS NOT NULL
                                FROM
                                    configuration_roletype_waiting_time AS c21
                                WHERE
                                    c21.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                LIMIT
                                    1
                            )
                        )
                        OR (
                            SELECT
                                c22.import_deletion_faild_requests_threshhold IS NOT NULL
                            FROM
                                configuration_roletype_waiting_time AS c22
                            WHERE
                                c22.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                            LIMIT
                                1
                        )
                        OR CASE
                            WHEN CAST(
                                (
                                    p1.importdate + (
                                        SELECT
                                            c23.import_threshhold_check
                                        FROM
                                            configuration_roletype_waiting_time AS c23
                                        WHERE
                                            c23.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                        LIMIT
                                            1
                                    )
                                ) at TIME ZONE 'UTC' AS date
                            ) < now()::TIMESTAMP::date THEN FALSE
                            ELSE TRUE
                        END
                        OR p1.importdate IS NULL
                        OR (
                            SELECT
                                c24.import_threshhold_check
                            FROM
                                configuration_roletype_waiting_time AS c24
                            WHERE
                                c24.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                            LIMIT
                                1
                        ) IS NULL
                    )
                    AND (
                        NOT (
                            (
                                SELECT
                                    c25.import_threshhold_check IS NOT NULL
                                FROM
                                    configuration_roletype_waiting_time AS c25
                                WHERE
                                    c25.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                LIMIT
                                    1
                            )
                        )
                        OR NOT (
                            (
                                SELECT
                                    c26.import_deletion_faild_requests_threshhold IS NOT NULL
                                FROM
                                    configuration_roletype_waiting_time AS c26
                                WHERE
                                    c26.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                LIMIT
                                    1
                            )
                        )
                        OR CASE
                            WHEN CAST(
                                (
                                    p1.importdate + (
                                        SELECT
                                            c27.import_threshhold_check
                                        FROM
                                            configuration_roletype_waiting_time AS c27
                                        WHERE
                                            c27.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                        LIMIT
                                            1
                                    )
                                ) at TIME ZONE 'UTC' AS date
                            ) < now()::TIMESTAMP::date THEN FALSE
                            ELSE TRUE
                        END
                        OR CASE
                            WHEN (
                                SELECT
                                    count(*)::INT
                                FROM
                                    (
                                        SELECT DISTINCT
                                            p9.id,
                                            p9.attribute,
                                            p9.created,
                                            p9.importdate,
                                            p9.lastmodificationdate,
                                            p9.lastmodifier,
                                            p9.personrole,
                                            p9.value,
                                            p9.version
                                        FROM
                                            personroledata AS p9
                                        WHERE
                                            p1.id = p9.personrole
                                            AND p9.attribute = 145
                                            AND (
                                                SELECT
                                                    MAX(date)
                                                FROM
                                                    (
                                                        SELECT
                                                            TO_DATE(
                                                                UNNEST(STRING_TO_ARRAY(p9.value, ',')),
                                                                'DD.MM.YYYY'
                                                            ) AS date,
                                                            '1' AS key
                                                    ) foo
                                                WHERE
                                                    p9.value NOT LIKE '∞'
                                                GROUP BY
                                                    key
                                            ) IS NOT NULL
                                            AND p1.importdate IS NOT NULL
                                            AND (
                                                SELECT
                                                    MAX(date)
                                                FROM
                                                    (
                                                        SELECT
                                                            TO_DATE(
                                                                UNNEST(STRING_TO_ARRAY(p9.value, ',')),
                                                                'DD.MM.YYYY'
                                                            ) AS date,
                                                            '1' AS key
                                                    ) foo
                                                WHERE
                                                    p9.value NOT LIKE '∞'
                                                GROUP BY
                                                    key
                                            ) > CAST(p1.importdate at TIME ZONE 'UTC' AS date)
                                    ) AS p10
                            ) > (
                                SELECT
                                    c28.import_deletion_faild_requests_threshhold
                                FROM
                                    configuration_roletype_waiting_time AS c28
                                WHERE
                                    c28.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                LIMIT
                                    1
                            ) THEN FALSE
                            ELSE TRUE
                        END
                        OR p1.importdate IS NULL
                        OR (
                            SELECT
                                c29.import_threshhold_check
                            FROM
                                configuration_roletype_waiting_time AS c29
                            WHERE
                                c29.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                            LIMIT
                                1
                        ) IS NULL
                    )
                    AND (
                        SELECT
                            max(
                                (
                                    SELECT
                                        MAX(date)
                                    FROM
                                        (
                                            SELECT
                                                TO_DATE(
                                                    UNNEST(STRING_TO_ARRAY(p11.value, ',')),
                                                    'DD.MM.YYYY'
                                                ) AS date,
                                                '1' AS key
                                        ) foo
                                    WHERE
                                        p11.value NOT LIKE '∞'
                                    GROUP BY
                                        key
                                ) + CASE
                                    WHEN p11.attribute = 110 THEN 1
                                    ELSE 0
                                END
                            )
                        FROM
                            personroledata AS p11
                        WHERE
                            p1.id = p11.personrole
                            AND p11.attribute::BIGINT in ( 42, 79, 110 )
                            AND (
                                p11.value NOT LIKE '%∞%'
                                OR p11.value IS NULL
                            )
                            AND (
                                SELECT
                                    MAX(date)
                                FROM
                                    (
                                        SELECT
                                            TO_DATE(
                                                UNNEST(STRING_TO_ARRAY(p11.value, ',')),
                                                'DD.MM.YYYY'
                                            ) AS date,
                                            '1' AS key
                                    ) foo
                                WHERE
                                    p11.value NOT LIKE '∞'
                                GROUP BY
                                    key
                            ) IS NOT NULL
                    ) IS NULL
                    AND p1.deleted IN (1, 10)
                ) THEN CAST(p1.deleted_on at TIME ZONE 'UTC' AS date)
                ELSE (
                    SELECT
                        min(v0."Value")
                    FROM
                        (
                            VALUES
                                (
                                    CAST(
                                        CASE
                                            WHEN (
                                                SELECT
                                                    c30.import_threshhold_check IS NOT NULL
                                                FROM
                                                    configuration_roletype_waiting_time AS c30
                                                WHERE
                                                    c30.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                                LIMIT
                                                    1
                                            )
                                            AND NOT (
                                                (
                                                    SELECT
                                                        c31.import_deletion_faild_requests_threshhold IS NOT NULL
                                                    FROM
                                                        configuration_roletype_waiting_time AS c31
                                                    WHERE
                                                        c31.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                                    LIMIT
                                                        1
                                                )
                                            )
                                            AND CAST(
                                                (
                                                    p1.importdate + (
                                                        SELECT
                                                            c32.import_threshhold_check
                                                        FROM
                                                            configuration_roletype_waiting_time AS c32
                                                        WHERE
                                                            c32.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                                        LIMIT
                                                            1
                                                    )
                                                ) at TIME ZONE 'UTC' AS date
                                            ) < now()::TIMESTAMP::date THEN CAST(
                                                (
                                                    p1.importdate + (
                                                        SELECT
                                                            c33.import_threshhold_check
                                                        FROM
                                                            configuration_roletype_waiting_time AS c33
                                                        WHERE
                                                            c33.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                                        LIMIT
                                                            1
                                                    )
                                                ) at TIME ZONE 'UTC' AS date
                                            )
                                        END AS date
                                    )
                                ),
                                (
                                    CASE
                                        WHEN (
                                            SELECT
                                                c34.import_threshhold_check IS NOT NULL
                                            FROM
                                                configuration_roletype_waiting_time AS c34
                                            WHERE
                                                c34.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                            LIMIT
                                                1
                                        )
                                        AND (
                                            SELECT
                                                c35.import_deletion_faild_requests_threshhold IS NOT NULL
                                            FROM
                                                configuration_roletype_waiting_time AS c35
                                            WHERE
                                                c35.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                            LIMIT
                                                1
                                        )
                                        AND CAST(
                                            (
                                                p1.importdate + (
                                                    SELECT
                                                        c36.import_threshhold_check
                                                    FROM
                                                        configuration_roletype_waiting_time AS c36
                                                    WHERE
                                                        c36.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                                    LIMIT
                                                        1
                                                )
                                            ) at TIME ZONE 'UTC' AS date
                                        ) < now()::TIMESTAMP::date
                                        AND (
                                            SELECT
                                                count(*)::INT
                                            FROM
                                                (
                                                    SELECT DISTINCT
                                                        p12.id,
                                                        p12.attribute,
                                                        p12.created,
                                                        p12.importdate,
                                                        p12.lastmodificationdate,
                                                        p12.lastmodifier,
                                                        p12.personrole,
                                                        p12.value,
                                                        p12.version
                                                    FROM
                                                        personroledata AS p12
                                                    WHERE
                                                        p1.id = p12.personrole
                                                        AND p12.attribute = 145
                                                        AND (
                                                            SELECT
                                                                MAX(date)
                                                            FROM
                                                                (
                                                                    SELECT
                                                                        TO_DATE(
                                                                            UNNEST(STRING_TO_ARRAY(p12.value, ',')),
                                                                            'DD.MM.YYYY'
                                                                        ) AS date,
                                                                        '1' AS key
                                                                ) foo
                                                            WHERE
                                                                p12.value NOT LIKE '∞'
                                                            GROUP BY
                                                                key
                                                        ) IS NOT NULL
                                                        AND p1.importdate IS NOT NULL
                                                        AND (
                                                            SELECT
                                                                MAX(date)
                                                            FROM
                                                                (
                                                                    SELECT
                                                                        TO_DATE(
                                                                            UNNEST(STRING_TO_ARRAY(p12.value, ',')),
                                                                            'DD.MM.YYYY'
                                                                        ) AS date,
                                                                        '1' AS key
                                                                ) foo
                                                            WHERE
                                                                p12.value NOT LIKE '∞'
                                                            GROUP BY
                                                                key
                                                        ) > CAST(p1.importdate at TIME ZONE 'UTC' AS date)
                                                ) AS p13
                                        ) > (
                                            SELECT
                                                c37.import_deletion_faild_requests_threshhold
                                            FROM
                                                configuration_roletype_waiting_time AS c37
                                            WHERE
                                                c37.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                            LIMIT
                                                1
                                        ) THEN CAST(
                                            (
                                                p1.importdate + (
                                                    SELECT
                                                        c38.import_threshhold_check
                                                    FROM
                                                        configuration_roletype_waiting_time AS c38
                                                    WHERE
                                                        c38.type_id @> ARRAY[p1.personroletype::INT]::INTEGER[]
                                                    LIMIT
                                                        1
                                                )
                                            ) at TIME ZONE 'UTC' AS date
                                        )
                                    END
                                ),
                                (
                                    (
                                        SELECT
                                            max(
                                                (
                                                    SELECT
                                                        MAX(date)
                                                    FROM
                                                        (
                                                            SELECT
                                                                TO_DATE(
                                                                    UNNEST(STRING_TO_ARRAY(p14.value, ',')),
                                                                    'DD.MM.YYYY'
                                                                ) AS date,
                                                                '1' AS key
                                                        ) foo
                                                    WHERE
                                                        p14.value NOT LIKE '∞'
                                                    GROUP BY
                                                        key
                                                ) + CASE
                                                    WHEN p14.attribute = 110 THEN 1
                                                    ELSE 0
                                                END
                                            )
                                        FROM
                                            personroledata AS p14
                                        WHERE
                                            p1.id = p14.personrole
                                            AND p14.attribute::BIGINT in ( 42, 79, 110 )
                                            AND (
                                                p14.value NOT LIKE '%∞%'
                                                OR p14.value IS NULL
                                            )
                                            AND (
                                                SELECT
                                                    MAX(date)
                                                FROM
                                                    (
                                                        SELECT
                                                            TO_DATE(
                                                                UNNEST(STRING_TO_ARRAY(p14.value, ',')),
                                                                'DD.MM.YYYY'
                                                            ) AS date,
                                                            '1' AS key
                                                    ) foo
                                                WHERE
                                                    p14.value NOT LIKE '∞'
                                                GROUP BY
                                                    key
                                            ) IS NOT NULL
                                    )
                                )
                        ) AS v0 ("Value")
                    WHERE
                        v0."Value" IS NOT NULL
                )
            END
    );