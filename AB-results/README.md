### Исследование результатов А/В-теста и поиск инсайтов

- **Описание:**  
Проведён анализ A/B‑теста обновлённого вводного онбординга в приложении для онлайн‑инвестиций на рынках Латинской Америки. Цель — оценить влияние углублённого обучения по рискам активов на поведение новых пользователей: конверсию в первые и повторные депозиты, а также общий объём вложений.

- **Технологии:**  
- Python  
- Jupyter Notebook  
- pandas
- Matplotlib
- seaborn
- NumPy  
- statsmodels
- SciPy (статистический анализ, бутстрап)  

- **Результаты:**  
1. **Основные метрики**  
   - Средний депозит на пользователя: +2.5% (не статистически значимо)  
   - Конверсия в первый депозит: –1.5% (не статистически значимо)  

2. **Повторные депозиты**  
   - Конверсия из первого во второй депозит: +12.4% (статистически значимо)  
   - Средний объём депозитов среди платящих: +4.4% (статистически значимо)  

3. **Сегментация по уровню риска**  
   - High‑risk: +18.3% повторных депозитов  
   - Medium‑risk: +2.5% (не значимо)  
   - Low‑risk: +7.6% повторных депозитов  

4. **Бутстрап‑анализ перцентилей**  
   - 25-й и 50-й перцентили уменьшились  
   - 75-й перцентиль значительно вырос  

5. **Выводы и рекомендации**  
   - Обучающий онбординг повышает вовлечённость самых рискованных инвесторов и рост повторных депозитов.  
   - Некоторая часть осторожных новичков отпугивается — стоит упростить первый шаг (бонус или минимальный депозит).  
   - Добавить целевую мотивацию для пользователей среднего уровня риска (например, пониженные комиссии).  
   - Рекомендовано внедрить обновлённый онбординг с доработками и продолжить мониторинг долгосрочных эффектов.  
