function angulo = my_atan(y, x)
    if x > 0
        angulo = atand(y / x);
    end
    if ((y >= 0) && (x < 0))
        angulo = 180 + atand(y / x);
    end
    if ((y < 0) && (x < 0))
        angulo = - 180 + atand(y/x);
    end
    if ((y > 0) && (x == 0))
        angulo = 90;
    end
    if ((y < 0) && (x == 0))
        angulo = -90;
    end
    if (angulo < 0)
        angulo = angulo + 360;
    end
end